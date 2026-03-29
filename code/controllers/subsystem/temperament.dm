SUBSYSTEM_DEF(temperament)
	name = "Temperament"
	flags = SS_NO_FIRE

	// format: /datum/temperament = initted/datum/temperament
	var/list/temperaments = list()
	// format: mob_uid = list(/datum/temperament, /datum/temperament/build, etc)
	var/list/who_got_what = list()

/datum/controller/subsystem/temperament/Initialize(timeofday)
	..()
	for(var/d in typesof(/datum/temperament))
		var/datum/temperament/T = new(d)
		temperaments[d] = T

/datum/controller/subsystem/temperament/proc/assign_temperament(mob/M, datum/temperament/T)
	var/muid = M.get_uid()
	if(!who_got_what[muid])
		who_got_what[muid] = list()
	var/save
	if(istype(T))
		save = T.type
	else if(ispath(T))
		save = T
	else
		CRASH("Tried to assign a temperament that wasn't a type or path!")
	who_got_what[muid] |= save
	return TRUE

/datum/controller/subsystem/temperament/proc/remove_temperament(mob/M, datum/temperament/T)
	var/muid = M.get_uid()
	if(!who_got_what[muid])
		return FALSE
	var/save
	if(istype(T))
		save = T.type
	else if(ispath(T))
		save = T
	else
		CRASH("Tried to remove a temperament that wasn't a type or path!")
	who_got_what[muid] -= save
	return TRUE

/datum/controller/subsystem/temperament/proc/get_textblock_for(mob/M)
	var/muid = M.get_uid()
	var/list/temps = who_got_what[muid]
	if(!temps)
		return null
	// grab a temperament, so we can use its pronounification
	var/datum/temperament/T
	for(var/t in temps)
		T = temperaments[t]
		if(T.temp_or_build == "temperament")
			break
	var/list/temps = list()
	var/list/builds = list()
	for(var/t in temps)
		var/datum/temperament/T = temperaments[t]
		if(T.temp_or_build == "temperament")
			temps |= T
		else if(T.temp_or_build == "build")
			builds |= T
	var/temperament_text = ""
	var/build_text = ""
	if(LAZYLEN(builds))
		var/prefix = "%THEY %IS"
		var/list/texts = list()
		for(var/datum/temperament/build/B in builds)
			texts += B.generate_text_for(M, LAZYLEN(temperament_text))
		build_text = prefix + english_list(texts)
	if(LAZYLEN(temps))
		// prefix is handled by temperament
		var/list/texts = list()
		for(var/datum/temperament/T in temps)
			texts += T.generate_text_for(M, LAZYLEN(build_text))
		temperament_text = texts.Join("\n")
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
 * 
 * Tense is assumed to be something like "They seem like they're a really chill guy who low key dgaf"
 */
// the key is the stringified path to the temperament, the value is the temperament itself
/datum/temperament
	var/name = "Really Chill Guy"
	var/prefix = "%THEY seem to be" // only for temperaments, not builds
	var/examinetext = "like %THEIR whole deal is %THEYRE a very chill %DUDER who low key dgaf"
	// background color for the temperment, when user is using light mode (usually something dark)
	var/spanuse = "notice"
	var/temp_or_build = "temperament"

/datum/temperament/build
	temp_or_build = "build"

// temperaments get assembled into a line that looks kinda like
// "He/She/They seem(s) like they're a really chill guy who low key dgaf"
// "He/She/They also seem(s) like they're a really chill guy who low key dgaf"
/datum/temperament/proc/generate_text_for(mob/M, also)
	var/text = ""
	var/pre_text = pronounify(M, prefix)
	var/ex_text = pronounify(M, examintext)
	if(also)
		decapitalize(ex_text)
		text += "Also, "
	colorize(M, ex_text)
	return text + ex_text

// builds are made to be inline with each other, just output a lowercased
/datum/temperament/build/generate_text_for(mob/M, also)
	var/ex_text = pronounify(M, examintext)
	decapitalize(ex_text)
	colorize(M, ex_text)
	return ex_text

// replaces the tokens with the right pronouns for the mob
/datum/temperament/proc/pronounify(mob/M, textin)
	// STRING OPERATIONS YAY
	switch(M.gender)
		if(MALE)
			textin = replacetext(examintext, "%THEYRE",   "he's")
			textin = replacetext(examintext, "%THEIR",    "his")
			textin = replacetext(examintext, "%THEY",     "he")
			textin = replacetext(examintext, "%SEEMS",    "seems")
			textin = replacetext(examintext, "%ARE",      "is")
			textin = replacetext(examintext, "%DUDER",    "guy")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "male")
		if(FEMALE)
			textin = replacetext(examintext, "%THEYRE",   "she's")
			textin = replacetext(examintext, "%THEIR",    "her")
			textin = replacetext(examintext, "%THEY",     "she")
			textin = replacetext(examintext, "%SEEMS",    "seems")
			textin = replacetext(examintext, "%ARE",      "is")
			textin = replacetext(examintext, "%DUDER",    "gal")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "female")
		else
			textin = replacetext(examintext, "%THEYRE",   "they're")
			textin = replacetext(examintext, "%THEIR",    "their")
			textin = replacetext(examintext, "%THEY",     "they")
			textin = replacetext(examintext, "%SEEMS",    "seem")
			textin = replacetext(examintext, "%ARE",      "are")
			textin = replacetext(examintext, "%DUDER",    "duder")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "[M.gender]")
	return textin

/datum/temperament/proc/getname(mob/M)
	if(M.name)
		return M.name
	else
		return "Someone"

/datum/temperament/proc/getspecies(mob/M)
	var/datum/preferences/P = extract_prefs(M)
	if(P?.custom_species)
		return P.custom_species
	var/datum/species/S = get_species(M)
	if(S)
		return S.name
	return "bingus fish"

/datum/temperament/proc/colorize(mob/M, textin)
	return "<span class=\"[spanuse]\">[textin]</span>"









