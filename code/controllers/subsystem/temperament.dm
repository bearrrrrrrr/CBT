SUBSYSTEM_DEF(temperament)
	name = "Temperament"
	flags = SS_NO_FIRE
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

/datum/controller/subsystem/temperament/proc/assign_temperament(mob/M, datum/temperament/T)
	if(!initialized)
		return FALSE
	var/muid = M.get_uid()
	if(!who_got_what[muid])
		who_got_what[muid] = list()
	var/save
	if(istext(T))
		T = text2path(T)
	if(istype(T))
		save = T.type
	else if(ispath(T))
		save = T
	else
		CRASH("Tried to assign a temperament that wasn't a type or path!")
	who_got_what[muid] |= save
	return TRUE

/datum/controller/subsystem/temperament/proc/remove_temperament(mob/M, datum/temperament/T)
	if(!initialized)
		return FALSE
	var/muid = M.get_uid()
	if(!who_got_what[muid])
		return FALSE
	var/save
	if(istext(T))
		T = text2path(T)
	if(istype(T))
		save = T.type
	else if(ispath(T))
		save = T
	else
		CRASH("Tried to remove a temperament that wasn't a type or path!")
	who_got_what[muid] -= save
	return TRUE

/datum/controller/subsystem/temperament/proc/update_temps(mob/M)
	if(!initialized)
		return FALSE
	var/muid = M.get_uid()
	if(!extract_client(M))
		return // only initialize for mobs with clients, no need to waste resources on npcs
	if(istype(M, /mob/dead))
		return // no need to update for dead people!
	var/datum/preferences/P = extract_prefs(M)
	if(islist(who_got_what[muid]))
		if(!P.temperaments_and_builds_needs_update)
			return // already initialized
	who_got_what[muid] = list()
	for(var/tnb_path in P.temperaments_and_builds)
		who_got_what[muid] |= tnb_path
	P.temperaments_and_builds_needs_update = FALSE

/datum/controller/subsystem/temperament/proc/get_temperaments(Z, builds_instead = FALSE)
	var/list/temps = list()
	if(istype(Z, /datum/preferences))
		var/datum/preferences/P = Z
		temps = P.temperaments_and_builds
	else if(istype(Z, /mob))
		var/mob/M = Z
		var/muid = M.get_uid()
		temps = who_got_what[muid]
	else
		CRASH("Tried to get temperaments for something that wasn't a mob or preferences! it was actually a [Z]")
	for(var/t in temps)
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
	return ret

/datum/controller/subsystem/temperament/proc/get_builds_for_prefs()
	return get_temperaments_for_prefs(TRUE) // hehe again

/datum/controller/subsystem/temperament/proc/get_temperament_textblock(Z)
	var/list/temps = get_temperaments(Z)
	if(!LAZYLEN(temps))
		return ""
	// prefix is handled by temperament
	var/list/texts = list()
	for(var/datum/temperament/T in temps)
		texts += T.generate_text_for(Z, LAZYLEN(temps))
	var/temperament_text = texts.Join("\n")
	return temperament_text

/datum/controller/subsystem/temperament/proc/get_build_textblock(Z)
	var/list/builds = get_builds(Z)
	if(!LAZYLEN(builds))
		return ""
	// formatted:
	// He is incredibly buttsome, and also is soft and squishy
	var/prefix = pronounify(Z, "%THEY %IS")
	var/list/texts = list()
	for(var/i in 1 to LAZYLEN(builds))
		var/datum/temperament/build/B = builds[i]
		texts += B.generate_text_for(Z, i != 1)
	var/build_text = "[prefix] [english_list(texts)]"
	return build_text

/datum/controller/subsystem/temperament/proc/get_textblock_for(Z)
	if(!initialized)
		return
	if(istype(Z, /mob))
		update_temps(Z)

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
	return build_text + "\n" + temperament_text

/* 
 * I love grammar! heres a list of usable tokens for the temperament text:
 * %THEYRE  - he's/she's/they're
 * %THEIR   - his/her/their
 * %THEY    - he/she/they
 * %NAME    - the mob's name
 * %SPECIES - the mob's species
 * %GENDER  - the mob's gender
 * %SEEMS   - seems/seems/seem
 * %ARE     - is/is/are
 * %HAS     - has/has/have
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
			textin = replacetext(textin, "%SEEMS",    "seems")
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
			textin = replacetext(textin, "%SEEMS",    "seems")
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
			textin = replacetext(textin, "%SEEMS",    "seem")
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
		text += "Also, "
	colorize(ex_text)
	return "[pre_text] [text][ex_text]"

// builds are made to be inline with each other, just output a lowercased
/datum/temperament/build/generate_text_for(Z, also)
	var/ex_text = SStemperament.pronounify(Z, examine_text)
	decapitalize(ex_text)
	colorize(ex_text)
	return "[ex_text]"

/datum/temperament/proc/colorize(textin)
	return "<span class=\"[spanuse]\">[textin]</span>"


/datum/temperament/debug_1
	name = "Really Chill Guy"
	prefix = "%THEY seem to be"
	examine_text = "like %THEIR whole deal is %THEYRE a very chill %DUDER who low key dgaf"
	spanuse = "love"
	temp_or_build = "temperament"

/datum/temperament/debug_2
	name = "Awesome cool bruddie"
	prefix = "%THEY are a trotal"
	examine_text = "like %THEYRE %THEIR %THEY %SEEMS %ARE %DUDER %NAME %SPECIES %GENDER and a really wanky cool"
	spanuse = "clown"
	temp_or_build = "temperament"

/datum/temperament/build/debug_1
	name = "Super buttsome individual"
	examine_text = "one HUGE awesome thing about %THEM is that %THEYRE super buttsome and everyone loves %THEM for that buttsome energy"
	spanuse = "love"
	temp_or_build = "temperament"

/datum/temperament/build/debug_2
	name = "buxom and soft"
	examine_text = "WOW they got them serious %THEYRE %THEIR %THEY %SEEMS %ARE %DUDER %NAME %SPECIES %GENDER badoneroonies"
	spanuse = "clown"
	temp_or_build = "temperament"

/// cus for SOME REASON I CANT TICK THE DAMN FILES, so theyre here

/* 
 * I love grammar! heres a list of usable tokens for the temperament text:
 * %THEYRE  - he's/she's/they're
 * %THEIR   - his/her/their
 * %THEY    - he/she/they
 * %NAME    - the mob's name
 * %SPECIES - the mob's species
 * %GENDER  - the mob's gender
 * %SEEMS   - seems/seems/seem
 * %ARE     - is/is/are
 * %HAS     - has/has/have
 * %DUDER   - guy/gal/duder
 * 
 * Tense is assumed to be something like "They seem like they're a really chill guy who low key dgaf"
 */

/// builds are prefixed with a pronounified "They are "

/datum/temperament/build/buxom
	name = "Buxom"
	examine_text = "%THEY %ARE a bit heavy chested"
	spanuse = "love"

/datum/temperament/build/broadshouldered
	name = "Broad Shouldered"
	examine_text = "%THEIR shoulders are wide and sturdy"
	spanuse = "love"

/datum/temperament/build/slender
	name = "Slender"
	examine_text = "%THEY %HAVE a thin, lightly built frame"
	spanuse = "love"

/datum/temperament/build/athletic
	name = "Athletic"
	examine_text = "%THEY %APPEARS fit and athletic"
	spanuse = "love"

/datum/temperament/build/stocky
	name = "Stocky"
	examine_text = "%THEY %ARE short and solidly built"
	spanuse = "love"

/datum/temperament/build/lithe
	name = "Lithe"
	examine_text = "%THEY %ARE slim"
	spanuse = "love"

/datum/temperament/build/lean
	name = "Lean"
	examine_text = "%THEY %HAVE little excess mass"
	spanuse = "love"

/datum/temperament/build/muscular
	name = "Muscular"
	examine_text = "%THEIR muscles are clearly defined"
	spanuse = "love"

/datum/temperament/build/burly
	name = "Burly"
	examine_text = "%THEY %ARE large and powerfully built"
	spanuse = "love"

/datum/temperament/build/petite
	name = "Petite"
	examine_text = "%THEY %ARE small and delicately built"
	spanuse = "love"

/datum/temperament/build/willowy
	name = "Willowy"
	examine_text = "%THEY %ARE narrow framed"
	spanuse = "love"

/datum/temperament/build/heavyset
	name = "Heavyset"
	examine_text = "%THEY %HAVE a broad body with extra weight"
	spanuse = "love"

/datum/temperament/build/curvy
	name = "Curvy"
	examine_text = "%THEIR body has rounded, flowing lines"
	spanuse = "love"

/datum/temperament/build/gangly
	name = "Gangly"
	examine_text = "%THEY %ARE compact and strongly built"
	spanuse = "love"

/datum/temperament/build/husky
	name = "Husky"
	examine_text = "%THEY %ARE large with a sturdy frame"
	spanuse = "love"

/datum/temperament/build/compact
	name = "Compact"
	examine_text = "%THEY %ARE small but well-proportioned"
	spanuse = "love"

/datum/temperament/build/chiseled
	name = "Chiseled"
	examine_text = "%THEIR features are sharply defined"
	spanuse = "love"

/datum/temperament/build/softbuilt
	name = "Soft-Built"
	examine_text = "%THEIR body has gentle contours"
	spanuse = "love"

/datum/temperament/build/topheavy
	name = "Top Heavy"
	examine_text = "%THEY %CARRY more mass in their upper body"
	spanuse = "love"

/datum/temperament/build/bottomheavy
	name = "Bottom Heavy"
	examine_text = "%THEY %CARRY more mass in their hips and legs"
	spanuse = "love"

/datum/temperament/build/barrelchested
	name = "Barrel Chested"
	examine_text = "%THEIR chest is wide and deep"
	spanuse = "love"

/datum/temperament/build/narrowframed
	name = "Narrow Framed"
	examine_text = "%THEIR skeletal frame is slim"
	spanuse = "love"

/datum/temperament/build/widehipped
	name = "Wide Hipped"
	examine_text = "%THEIR hips are broader than average"
	spanuse = "love"

/datum/temperament/build/longtorsoed
	name = "Long Torsoed"
	examine_text = "%THEIR torso is longer than their legs"
	spanuse = "love"

/datum/temperament/build/longlegged
	name = "Long Legged"
	examine_text = "%THEIR legs are noticeably long"
	spanuse = "love"

/datum/temperament/build/shortlimbed
	name = "Short Limbed"
	examine_text = "%THEIR arms and legs are shorter in proportion"
	spanuse = "love"

/datum/temperament/build/delicateboned
	name = "Delicate Boned"
	examine_text = "%THEIR bones APPEARS fine and light"
	spanuse = "love"

/datum/temperament/build/solidlybuilt
	name = "Solidly Built"
	examine_text = "%THEY %APPEARS dense and durable"
	spanuse = "love"

/datum/temperament/build/hourglass
	name = "Hourglass"
	examine_text = "%THEIR waist is narrow"
	spanuse = "love"

/datum/temperament/build/rectanglebuilt
	name = "Rectangle Built"
	examine_text = "%THEIR chest, waist, and hips align evenly"
	spanuse = "love"

/datum/temperament/build/pearshaped
	name = "Pear Shaped"
	examine_text = "%THEIR hips are wider than their shoulders"
	spanuse = "love"

/datum/temperament/build/invertedtriangle
	name = "Inverted Triangle"
	examine_text = "%THEIR shoulders are wider than their hips"
	spanuse = "love"

/datum/temperament/build/thickthighed
	name = "Thick Thighed"
	examine_text = "%THEIR thighs are strong and full"
	spanuse = "love"

/datum/temperament/build/narrowwaisted
	name = "Narrow Waisted"
	examine_text = "%THEIR waist is noticeably slim"
	spanuse = "love"

/datum/temperament/build/densebuilt
	name = "Densely Built"
	examine_text = "%THEIR skeletal structure seems dense"
	spanuse = "love"

/datum/temperament/build/broad
	name = "Broad"
	examine_text = "%THEIR skeletal structure is wide"
	spanuse = "love"

/datum/temperament/build/lightlybuilt
	name = "Lightly Built"
	examine_text = "%THEY %LOOKS very light"
	spanuse = "love"

/datum/temperament/build/ruggedlybuilt
	name = "Ruggedly Built"
	examine_text = "%THEY %LOOKS pretty ruggedly built"
	spanuse = "love"

/datum/temperament/build/average
	name = "Average"
	examine_text = "%THEY %HAVE no extreme features"
	spanuse = "love"

/datum/temperament/build/plush
	name = "Plush"
	examine_text = "%THEY %ARE pleasantly plump and soft"
	spanuse = "love"

/datum/temperament/build/chubby
	name = "Chubby"
	examine_text = "%THEY %LOOKS pretty darn chubby"
	spanuse = "love"

/datum/temperament/build/fat
	name = "Fat"
	examine_text = "%THEY %LOOKS quite well-fed"
	spanuse = "love"

/datum/temperament/build/obese
	name = "Obese"
	examine_text = "%THEY %LOOKS exceptionally blubbery"
	spanuse = "love"

/datum/temperament/build/morbidlyobese
	name = "Morbidly Obese"
	examine_text = "%THEY %LOOKS extremely obese"
	spanuse = "love"

/datum/temperament/build/extremelybuxom
	name = "Extremely Buxom"
	examine_text = "%THEY %HAVE some extremely massive breasts"
	spanuse = "love"

/datum/temperament/build/morphable
	name = "Morphable"
	examine_text = "%THEIR body seems a bit amorphous"
	spanuse = "love"

/datum/temperament/build/swimmer
	name = "Swimmer"
	examine_text = "%THEY %HAVE a long, swimmer's body"
	spanuse = "love"

/datum/temperament/build/androgynous
	name = "Androgynous"
	examine_text = "%THEY %SEEMS rather androgynous"
	spanuse = "love"

/datum/temperament/build/masculinepresenting
	name = "Masculine Presenting"
	examine_text = "%THEY %SEEMS to be rather masculine-presenting"
	spanuse = "love"

/datum/temperament/build/femininepresenting
	name = "Feminine Presenting"
	examine_text = "%THEY %SEEMS to be rather feminine-presenting"
	spanuse = "love"

/datum/temperament/build/fluffy
	name = "Fluffy"
	examine_text = "%THEY %LOOKS soft and fluffy"
	spanuse = "love"

/datum/temperament/build/extremelyfluffy
	name = "Extremely Fluffy"
	examine_text = "%THEY %LOOKS REALLY soft and REALLY fluffy"
	spanuse = "love"

/datum/temperament/build/jacked
	name = "Jacked"
	examine_text = "%THEY %ARE absolutely RIPPED"
	spanuse = "love"

/datum/temperament/build/shortstack
	name = "Shortstack"
	examine_text = "%THEY is short and well filled out"
	spanuse = "love"

/datum/temperament/build/buttsum
	name = "Buttsome"
	examine_text = "%THEY got a butt built like a brick house"
	spanuse = "love"

/datum/temperament/build/extremelybuttsum
	name = "EXTREMELY Buttsome"
	examine_text = "%THEY has a rear end that might have its own gravity well"
	spanuse = "love"

/datum/temperament/build/flatchested
	name = "Flat Chested"
	examine_text = "%THEY is pretty flat chested"
	spanuse = "love"

/datum/temperament/build/flatassed
	name = "Flat Assed"
	examine_text = "%THEY has a flat rear end"
	spanuse = "love"


/* 
 * I love grammar! heres a list of usable tokens for the temperament text:
 * %THEYRE  - he's/she's/they're
 * %THEIR   - his/her/their
 * %THEY    - he/she/they
 * %NAME    - the mob's name
 * %SPECIES - the mob's species
 * %GENDER  - the mob's gender
 * %SEEMS   - seems/seems/seem
 * %ARE     - is/is/are
 * %HAS     - has/has/have
 * %DUDER   - guy/gal/duder
 * 
 * Tense is assumed to be something like "They seem like they're a really chill guy who low key dgaf"
 */

/// they show up as [prefix] [examine_text]
/datum/temperament/aggressive
	name = "Aggressive"
	prefix = "%THEY seem"
	examine_text = "kind of aggressive, but it might be a front."
	spanuse = "notice"

/datum/temperament/anxious
	name = "Anxious"
	prefix = "%THEY seem"
	examine_text = "kind of anxious and on edge!"
	spanuse = "notice"

/datum/temperament/bratty
	name = "Bratty"
	prefix = "%THEY seem"
	examine_text = "kind of bratty and combative!"
	spanuse = "notice"

/datum/temperament/calm
	name = "Calm"
	prefix = "%THEY seem"
	examine_text = "to be calm natured."
	spanuse = "notice"

/datum/temperament/confident
	name = "Confident"
	prefix = "%THEY seem"
	examine_text = "confident, like %THEY really %KNOWS-AAA what %THEYRE doing."
	spanuse = "notice"

/datum/temperament/cuddly
	name = "Cuddly"
	prefix = "%THEY seem"
	examine_text = "soft and squishable!"
	spanuse = "notice"

/datum/temperament/curious
	name = "Curious"
	prefix = "%THEY seem"
	examine_text = "really curious about things."
	spanuse = "notice"

/datum/temperament/distracted
	name = "Distracted"
	prefix = "%THEY seem"
	examine_text = "kind of distracted on other things!"
	spanuse = "notice"

/datum/temperament/dopey
	name = "Dopey"
	prefix = "%THEY seem"
	examine_text = "a bit uh - well. A bit dopey. A bit not all there."
	spanuse = "notice"

/datum/temperament/dorky
	name = "Dorky"
	prefix = "%THEY seem"
	examine_text = "a little socially awkward, but not maliciously so."
	spanuse = "notice"

/datum/temperament/eager
	name = "Eager"
	prefix = "%THEY seem"
	examine_text = "eager!  Almost like a puppy."
	spanuse = "notice"

/datum/temperament/easygoing
	name = "Easygoing"
	prefix = "%THEY seem"
	examine_text = "easy going, like life is just a-okay for them."
	spanuse = "notice"

/datum/temperament/flighty
	name = "Flighty"
	prefix = "%THEY seem"
	examine_text = "very flighty, but they seem to enjoy the chase."
	spanuse = "notice"

/datum/temperament/flirty
	name = "Flirty"
	prefix = "%THEY seem"
	examine_text = "kind of flirty and prone to teasing!"
	spanuse = "notice"

/datum/temperament/forward
	name = "Forward"
	prefix = "%THEY seem"
	examine_text = "like %THEYRE willing to say what %THEYRE thinking."
	spanuse = "notice"

/datum/temperament/friendly
	name = "Friendly"
	prefix = "%THEY seem"
	examine_text = "friendly!"
	spanuse = "notice"

/datum/temperament/gentle
	name = "Gentle"
	prefix = "%THEY seem"
	examine_text = "to be quite gentle."
	spanuse = "notice"

/datum/temperament/gregarious
	name = "Gregarious"
	prefix = "%THEY seem"
	examine_text = "kind of outgoing and prone to laughter!"
	spanuse = "notice"

/datum/temperament/indifferent
	name = "Indifferent"
	prefix = "%THEY seem"
	examine_text = "kind of aloof and indifferent!"
	spanuse = "notice"

/datum/temperament/innocent
	name = "Innocent"
	prefix = "%THEY seem"
	examine_text = "really innocent. How surprising."
	spanuse = "notice"

/datum/temperament/lazy
	name = "Lazy"
	prefix = "%THEY seem"
	examine_text = "to be kind of lazy."
	spanuse = "notice"

/datum/temperament/lonely
	name = "Lonely"
	prefix = "%THEY seem"
	examine_text = "to be kind of lonely, but approachable!"
	spanuse = "notice"

/datum/temperament/mature // mtndew
	name = "Mature"
	prefix = "%THEY seem"
	examine_text = "very mature, in a sort of 'parenty' way."
	spanuse = "notice"

/datum/temperament/melancholic
	name = "Melancholic"
	prefix = "%THEY seem"
	examine_text = "down, and in need of some love!"
	spanuse = "notice"

/datum/temperament/modest
	name = "Modest"
	prefix = "%THEY seem"
	examine_text = "to be modest, in a way."
	spanuse = "notice"

/datum/temperament/naive
	name = "Naive"
	prefix = "%THEY seem"
	examine_text = "to be naive."
	spanuse = "notice"

/datum/temperament/rebellious
	name = "Rebellious"
	prefix = "%THEY seem"
	examine_text = "to have an aire of the rebellious to them."
	spanuse = "notice"

/datum/temperament/relaxed
	name = "Relaxed"
	prefix = "%THEY seem"
	examine_text = "to just be very relaxed."
	spanuse = "notice"

/datum/temperament/ruffled
	name = "Ruffled"
	prefix = "%THEY seem"
	examine_text = "a bit frazzled!"
	spanuse = "notice"

/datum/temperament/shy
	name = "Shy"
	prefix = "%THEY seem"
	examine_text = "to be kinda shy, but approachable!"
	spanuse = "notice"

/datum/temperament/silly
	name = "Silly"
	prefix = "%THEY seem"
	examine_text = "to be just kind of silly."
	spanuse = "notice"

/datum/temperament/smart
	name = "Smart"
	prefix = "%THEY seem"
	examine_text = "smart. In a bookish kind of way."
	spanuse = "notice"

/datum/temperament/timid
	name = "Timid"
	prefix = "%THEY seem"
	examine_text = "to be a bit timid."
	spanuse = "notice"

/datum/temperament/tired
	name = "Tired"
	prefix = "%THEY seem"
	examine_text = "kind of tired and sleepy!"
	spanuse = "notice"

/datum/temperament/trustworthy
	name = "Trustworthy"
	prefix = "%THEY seem"
	examine_text = "like the trustworthy sort! Probably."
	spanuse = "notice"

/datum/temperament/warm
	name = "Warm"
	prefix = "%THEY seem"
	examine_text = "warm, physically or emotionally."
	spanuse = "notice"



