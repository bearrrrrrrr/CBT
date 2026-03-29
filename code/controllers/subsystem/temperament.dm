SUBSYSTEM_DEF(temperament)
	name = "Temperament"
	flags = SS_NO_FIRE

	// format: "/datum/temperament" = /datum/temperament
	var/list/temperaments = list()
	// format: "/datum/temperament/build" = /datum/temperament/build
	var/list/builds = list()

/datum/controller/subsystem/temperament/Initialize(timeofday)
	..()
/* 
 * I love grammar! heres a list of usable tokens for the temperament text:
 * %THEYRE  - he's/she's/they're
 * %THEIR   - his/her/their
 * %THEY    - he/she/they
 * %NAME    - the mob's name
 * %SPECIES - the mob's species
 * %GENDER  - the mob's gender
 * %SEEMS   - seems/seems/seem
 * %IS      - is/is/are
 * %HAS     - has/has/have
 * %DUDER   - guy/gal/duder
 * 
 * Tense is assumed to be something like "They seem like they're a really chill guy who low key dgaf"
 */
// the key is the stringified path to the temperament, the value is the temperament itself
/datum/temperament
	var/name = "Really Chill Guy"
	var/prefix = "%THEY seem to be"
	var/examinetext = "like %THEIR whole deal is %THEYRE a very chill %DUDER who low key dgaf"
	// background color for the temperment, when user is using light mode (usually something dark)
	var/color_lightmode = "#000000"
	// background color for the temperment, when user is using dark mode (usually something light)
	var/color_darkmode = "#FFFFFF"
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
	colorize(M, ex_text)
	if(also)
		decapitalize(ex_text)
		text += "Also, "
	return text + ex_text

// builds are made to be inline with each other, just output a lowercased
/datum/temperament/build/proc/generate_text_for(mob/M, also)
	var/text = ""
	var/pre_text = pronounify(M, prefix)
	var/ex_text = pronounify(M, examintext)
	colorize(M, ex_text)
	if(also)
		decapitalize(ex_text)
		text += "Also, "
	return text + ex_text

// replaces the tokens with the right pronouns for the mob
/datum/temperament/proc/pronounify(mob/M, textin)
	// STRING OPERATIONS YAY
	switch(M.gender)
		if(MALE)
			textin = replacetext(examintext, "%THEYRE",   "he's")
			textin = replacetext(examintext, "%THEIR",    "his")
			textin = replacetext(examintext, "%THEY",     "he")
			textin = replacetext(examintext, "%SEEMS",    "seems")
			textin = replacetext(examintext, "%IS",       "is")
			textin = replacetext(examintext, "%DUDER",    "guy")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "male")
		if(FEMALE)
			textin = replacetext(examintext, "%THEYRE",   "she's")
			textin = replacetext(examintext, "%THEIR",    "her")
			textin = replacetext(examintext, "%THEY",     "she")
			textin = replacetext(examintext, "%SEEMS",    "seems")
			textin = replacetext(examintext, "%IS",       "is")
			textin = replacetext(examintext, "%DUDER",    "gal")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "female")
		else
			textin = replacetext(examintext, "%THEYRE",   "they're")
			textin = replacetext(examintext, "%THEIR",    "their")
			textin = replacetext(examintext, "%THEY",     "they")
			textin = replacetext(examintext, "%SEEMS",    "seem")
			textin = replacetext(examintext, "%IS",       "are")
			textin = replacetext(examintext, "%DUDER",    "duder")
			textin = replacetext(examintext, "%NAME",     getname(M))
			textin = replacetext(examintext, "%SPECIES",  getspecies(M))
			textin = replacetext(examintext, "%GENDER",   "nonbinary")
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











