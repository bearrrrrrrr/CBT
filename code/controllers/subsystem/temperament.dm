SUBSYSTEM_DEF(temperament)
	name = "Temperament"
	flags = SS_BACKGROUND
	wait = 30 SECONDS
	init_order = INIT_ORDER_QUIRKS // cus its quirky

	// format: /datum/temperament = initted/datum/temperament
	var/list/temperaments = list()
	// format: mob_uid = list(/datum/temperament, /datum/temperament/build, etc)
	var/list/who_got_what = list()

/datum/controller/subsystem/temperament/Initialize(timeofday)
	for(var/d in subtypesof(/datum/temperament) - /datum/temperament/build)
		var/datum/temperament/T = d
		if(initial(T.dont_use))
			continue
		T = new d()
		temperaments[d] = T
	..()
	to_chat(world, span_greenannounce("Initialized [LAZYLEN(temperaments)] temperaments and/or builds! =3"))

/datum/controller/subsystem/temperament/fire(resumed)
	for(var/cli_key in GLOB.directory)
		var/client/C = GLOB.directory[cli_key]
		if(C && isliving(C.mob))
			update_tnb(C.mob)

/datum/controller/subsystem/temperament/proc/update_tnb(mob/M)
	if(!initialized)
		return FALSE
	if(!istype(M, /mob/living))
		return // no need to update for dead people!
	if(!extract_client(M))
		return // only initialize for mobs with clients, no need to waste resources on npcs
	var/muid = M.get_uid()
	var/datum/preferences/P = extract_prefs(M)
	who_got_what[muid] = list()
	for(var/tnb_path in P.temperaments_and_builds)
		who_got_what[muid] |= tnb_path

// tries to get the Most Truthfulness temperaments and builds for the player
// first tries to pull it from preferences, then if it fails, gets it from the
// mob's uid, but only if they're a living
// otherwise returns an empty list
/datum/controller/subsystem/temperament/proc/get_tnb_holder(Z)
	var/datum/preferences/P = extract_prefs(Z)
	if(P)
		return P.temperaments_and_builds
	else if(isliving(Z))
		var/mob/living/L = Z
		update_tnb(L)
		return who_got_what[L.get_uid()]
	return list()

/datum/controller/subsystem/temperament/proc/get_temperaments(Z, builds_instead = FALSE)
	var/list/temps = list()
	var/list/temp_holder = get_tnb_holder(Z)
	for(var/t in temp_holder)
		var/datum/temperament/T = temperaments[t]
		if(builds_instead)
			if(T.temp_or_build == "build")
				temps += temperaments[t]
		else
			if(T.temp_or_build == "temperament")
				temps += temperaments[t]
	return temps

/datum/controller/subsystem/temperament/proc/get_builds(Z)
	return get_temperaments(Z, TRUE) // hehehe

/datum/controller/subsystem/temperament/proc/get_temperaments_for_prefs(builds_instead = FALSE)
	// format: list("cool guy" = /datum/temperament/reallychillguy, "buxom and soft" = /datum/temperament/build/debug_2, etc)
	var/list/ret = list()
	for(var/t in temperaments)
		var/datum/temperament/T = temperaments[t]
		if(builds_instead && T.temp_or_build == "build")
			ret[T.name] = T
		else if(!builds_instead && T.temp_or_build == "temperament")
			ret[T.name] = T
	return sort_list(ret, /proc/cmp_text_asc)

/datum/controller/subsystem/temperament/proc/get_builds_for_prefs()
	return get_temperaments_for_prefs(TRUE) // hehe again

/datum/controller/subsystem/temperament/proc/get_temperament_textblock(Z)
	var/list/temps = get_temperaments(Z)
	if(!LAZYLEN(temps))
		return ""
	// prefix is handled by temperament
	var/list/texts = list()
	for(var/i in 1 to LAZYLEN(temps))
		var/datum/temperament/T = temps[i]
		texts += capitalize(T.generate_text_for(Z, i != 1))
	var/temperament_text = texts.Join("\n")
	return temperament_text

/datum/controller/subsystem/temperament/proc/get_build_textblock(Z)
	var/list/builds = get_builds(Z)
	if(!LAZYLEN(builds))
		return ""
	// formatted:
	// He is incredibly buttsome, and also is soft and squishy
	// var/prefix = pronounify(Z, "%THEY %ARE")
	var/list/texts = list()
	for(var/i in 1 to LAZYLEN(builds))
		var/datum/temperament/build/B = builds[i]
		texts += B.generate_text_for(Z, i != 1)
	var/build_text = capitalize("[english_list(texts, and_text = ", and ")]")
	return build_text

/datum/controller/subsystem/temperament/proc/get_textblock_for(Z)
	if(!initialized)
		return
	var/temperament_text = get_temperament_textblock(Z)
	var/build_text = get_build_textblock(Z)
	var/has_builds = LAZYLEN(build_text)
	var/has_temps = LAZYLEN(temperament_text)
	if(!has_builds && !has_temps)
		return ""
	var/msg = ""
	if(has_builds)
		msg += build_text
	if(has_builds && has_temps)
		msg += "\n"
	if(has_temps)
		msg += temperament_text
	return msg

/* 
 * I love grammar! heres a list of usable tokens for the temperament text:
 * %THEYRE  - he's/she's/they're
 * %THEIR   - his/her/their
 * %THEY    - he/she/they
 * %NAME    - the mob's name
 * %SPECIES - the mob's species
 * %GENDER  - the mob's gender
 * %SEEM   - seems/seems/seem
 * %ARE     - is/is/are
 * %HAVE     - has/has/have
 * %DUDER   - guy/gal/duder
 * %HAVE    - has/has/have
 * %APPEARS - appears/appears/appear
 * %CARRY   - carries/carries/carry
 * %LOOKS   - looks/looks/look
 * %KNOWS   - knows/knows/know
 * 
 * Tense is assumed to be something like "They seem like they're a really chill guy who low key dgaf"
 */
// replaces the tokens with the right pronouns for the mob
/datum/controller/subsystem/temperament/proc/pronounify(Z, textin)
	if(!textin)
		return "hey this didnt have a textin for some reason oops"
	var/gendy = extract_gender(Z)
	var/species = get_species_name(Z)
	var/maybename = get_mob_name(Z)
	// STRING OPERATIONS YAY
	switch(gendy)
		if(MALE)
			textin = replacetext(textin, "%THEYRE",   "he's")
			textin = replacetext(textin, "%THEIR",    "his")
			textin = replacetext(textin, "%THEY",     "he")
			textin = replacetext(textin, "%SEEM",    "seems")
			textin = replacetext(textin, "%ARE",      "is")
			textin = replacetext(textin, "%DUDER",    "guy")
			textin = replacetext(textin, "%NAME",     maybename)
			textin = replacetext(textin, "%SPECIES",  species)
			textin = replacetext(textin, "%GENDER",   "male")
			textin = replacetext(textin, "%HAVE",     "has")
			textin = replacetext(textin, "%APPEARS",  "appears")
			textin = replacetext(textin, "%CARRY",    "carries")
			textin = replacetext(textin, "%LOOKS",    "looks")
			textin = replacetext(textin, "%KNOWS",    "knows")
		if(FEMALE)
			textin = replacetext(textin, "%THEYRE",   "she's")
			textin = replacetext(textin, "%THEIR",    "her")
			textin = replacetext(textin, "%THEY",     "she")
			textin = replacetext(textin, "%SEEM",    "seems")
			textin = replacetext(textin, "%ARE",      "is")
			textin = replacetext(textin, "%DUDER",    "gal")
			textin = replacetext(textin, "%NAME",     maybename)
			textin = replacetext(textin, "%SPECIES",  species)
			textin = replacetext(textin, "%GENDER",   "female")
			textin = replacetext(textin, "%HAVE",     "has")
			textin = replacetext(textin, "%APPEARS",  "appears")
			textin = replacetext(textin, "%CARRY",    "carries")
			textin = replacetext(textin, "%LOOKS",    "looks")
			textin = replacetext(textin, "%KNOWS",    "knows")
		else
			textin = replacetext(textin, "%THEYRE",   "they're")
			textin = replacetext(textin, "%THEIR",    "their")
			textin = replacetext(textin, "%THEY",     "they")
			textin = replacetext(textin, "%SEEM",    "seem")
			textin = replacetext(textin, "%ARE",      "are")
			textin = replacetext(textin, "%DUDER",    "duder")
			textin = replacetext(textin, "%NAME",     maybename)
			textin = replacetext(textin, "%SPECIES",  species)
			textin = replacetext(textin, "%GENDER",   "[gendy]")
			textin = replacetext(textin, "%HAVE",     "have")
			textin = replacetext(textin, "%APPEARS",  "appear")
			textin = replacetext(textin, "%CARRY",    "carry")
			textin = replacetext(textin, "%LOOKS",    "look")
			textin = replacetext(textin, "%KNOWS",    "know")
	return textin

/datum/controller/subsystem/temperament/proc/get_species_name(Z)
	var/datum/preferences/P = extract_prefs(Z)
	if(P?.custom_species)
		return P.custom_species
	var/datum/species/maybespecies = P.pref_species
	if(maybespecies)
		return maybespecies.name
	return "bingus fish" //the proverbial 'bish'

/datum/controller/subsystem/temperament/proc/get_mob_name(Z)
	if(istype(Z, /mob))
		var/mob/M = Z
		return M.name
	else if(istype(Z, /datum/preferences))
		var/datum/preferences/P = Z
		return P.real_name
	else
		return "Someone"

// ouch!
/proc/extract_gender(Z)
	if(istype(Z, /mob))
		var/mob/M = Z
		return M.gender
	if(istype(Z, /datum/preferences))
		var/datum/preferences/P = Z
		return P.gender
	return NEUTER

// the key is the stringified path to the temperament, the value is the temperament itself
/datum/temperament
	var/name = "Really Chill Guy"
	var/prefix = "%THEY seem to be" // only for temperaments, not builds
	var/examine_text = "like %THEIR whole deal is %THEYRE a very chill %DUDER who low key dgaf"
	// background color for the temperment, when user is using light mode (usually something dark)
	var/spanuse = "notice"
	var/temp_or_build = "temperament"
	var/dont_use = FALSE

/datum/temperament/build
	temp_or_build = "build"

// temperaments get assembled into a line that looks kinda like
// "He/She/They seem(s) like they're a really chill guy who low key dgaf"
// "He/She/They also seem(s) like they're a really chill guy who low key dgaf"
/datum/temperament/proc/generate_text_for(Z, also)
	var/text = ""
	var/pre_text = SStemperament.pronounify(Z, prefix)
	var/ex_text = SStemperament.pronounify(Z, examine_text)
	if(also)
		decapitalize(ex_text)
		text += "also, "
	colorize(ex_text)
	return "[text][pre_text] [ex_text]"

// builds are made to be inline with each other, just output a lowercased
/datum/temperament/build/generate_text_for(Z, also)
	var/ex_text = SStemperament.pronounify(Z, examine_text)
	decapitalize(ex_text)
	colorize(ex_text)
	return "[ex_text]"

/datum/temperament/proc/colorize(textin)
	return "<span class=\"[spanuse]\">[textin]</span>"


