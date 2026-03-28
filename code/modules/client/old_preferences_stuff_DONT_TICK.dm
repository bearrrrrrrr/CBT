/* dont tick this file */
/* 
 * This is stuff i pulled out of the prefs menu that i couldntr bring myself to delete
 * but it cant just sit there as enormous blocks of comments, looks wretched
 */

// Simple Creature Thign

			//Start Creature Character
			dat += "<h2>Simple Creature Character</h2>"
			dat += "<b>Creature Species</b><a style='display:block;width:100px' href='?_src_=prefs;preference=creature_species;task=input'>[creature_species ? creature_species : "Eevee"]</a><BR>"
			dat += "<b>Creature Name</b><a style='display:block;width:100px' href='?_src_=prefs;preference=creature_name;task=input'>[creature_name ? creature_name : "Eevee"]</a><BR>"
			/*
			if(CONFIG_GET(number/body_size_min) != CONFIG_GET(number/body_size_max))
				dat += "<b>Size:</b> <a href='?_src_=prefs;preference=creature_body_size;task=input'>[creature_body_size*100]%</a><br>"
			dat += "<b>Scaling:</b> <a href='?_src_=prefs;preference=creature_toggle_fuzzy;task=input'>[creature_fuzzy ? "Fuzzy" : "Sharp"]</a><br>"
			*/
			dat += "<a href='?_src_=prefs;preference=creature_flavor_text;task=input'><b>Set Creature Examine Text</b></a><br>"
			if(length(creature_flavor_text) <= 40)
				if(!length(creature_flavor_text))
					dat += "\[...\]<br>"
				else
					dat += "[creature_flavor_text]<br>"
			else
				dat += "[TextPreview(creature_flavor_text)]...<br>"
			dat += "<a href='?_src_=prefs;preference=creature_ooc;task=input'><b>Set Creature OOC Notes</b></a><br>"
			if(length(creature_ooc) <= 40)
				if(!length(creature_ooc))
					dat += "\[...\]<br>"
				else
					dat += "[creature_ooc]<br>"
			else
				dat += "[TextPreview(creature_ooc)]...<br>"
			if(creature_species)
				if(!LAZYLEN(GLOB.creature_selectable))
					generate_selectable_creatures()
				if(!(creature_species in GLOB.creature_selectable))
					creature_species = initial(creature_species)
				dat += "[icon2base64html(GLOB.creature_selectable_icons[creature_species])]<br>"
			// End creature Character

			dat += "</td>"

// bg info
			dat += "<a href='?_src_=prefs;preference=background_info_notes;task=input'><b>Set Background Info Notes</b></a><br>"
			var/background_info_notes_len = length(features["background_info_notes"])
			if(background_info_notes_len <= 40)
				if(!background_info_notes_len)
					dat += "\[...\]<br>"
				else
					dat += "[features["background_info_notes"]]<br>"
			else
				dat += "[TextPreview(features["background_info_notes"])]...<br>"

			//outside link stuff
			dat += "<h3>Outer hyper-links settings</h3>"
			dat += "<a href='?_src_=prefs;preference=flist;task=input'><b>Set F-list link</b></a><br>"
			var/flist_len = length(features["flist"])
			if(flist_len <= 40)
				if(!flist_len)
					dat += "\[...\]"
				else
					dat += "[features["flist"]]"
			else
				dat += "[TextPreview(features["flist"])]...<br>"

			dat += "</td>"
			dat += APPEARANCE_CATEGORY_COLUMN

// custom say verbs
			dat += APPEARANCE_CATEGORY_COLUMN
			dat += "<center><h2>Custom Say Verbs</h2></center>"
			dat += "<a href='?_src_=prefs;preference=custom_say;verbtype=custom_say;task=input'>Says</a>"
			dat += "<BR><a href='?_src_=prefs;preference=custom_say;verbtype=custom_whisper;task=input'>Whispers</a>"
			dat += "<BR><a href='?_src_=prefs;preference=custom_say;verbtype=custom_ask;task=input'>Asks</a>"
			dat += "<BR><a href='?_src_=prefs;preference=custom_say;verbtype=custom_exclaim;task=input'>Exclaims</a>"
			dat += "<BR><a href='?_src_=prefs;preference=custom_say;verbtype=custom_yell;task=input'>Yells</a>"
			dat += "<BR><a href='?_src_=prefs;preference=custom_say;verbtype=custom_sing;task=input'>Sings</a>"
			//dat += "<BR><a href='?_src_=prefs;preference=soundindicatorpreview'>Preview Sound Indicator</a><BR>"
			dat += "</td>"




			/*Uplink choice disabled since not implemented, pointless button
			dat += "<b>Uplink Location:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=uplink_loc;task=input'>[uplink_spawn_loc]</a>"
			dat += "</td>"*/

			/// HA HA! I HAVE DELETED YOUR PRECIOUS NAUGHTY PARTS, YOU HORNY ANIMALS! 
			/* dat +="<td width='220px' height='300px' valign='top'>" //
			if(NOGENITALS in pref_species.species_traits)
				dat += "<b>Your species ([pref_species.name]) does not support genitals!</b><br>"
			else
				dat += "<h3>Penis</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_cock'>[features["has_cock"] == TRUE ? "Yes" : "No"]</a>"
				if(features["has_cock"])
					if(!pref_species.use_skintones)
						dat += "<b>Penis Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: #[features["cock_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=cock_color;task=input'>Change</a><br>"
					var/tauric_shape = FALSE
					if(features["cock_taur"])
						var/datum/sprite_accessory/penis/P = GLOB.cock_shapes_list[features["cock_shape"]]
						if(P.taur_icon && parent.can_have_part("taur"))
							var/datum/sprite_accessory/taur/T = GLOB.taur_list[features["taur"]]
							if(T.taur_mode & P.accepted_taurs)
								tauric_shape = TRUE
					dat += "<b>Penis Shape:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_shape;task=input'>[features["cock_shape"]][tauric_shape ? " (Taur)" : ""]</a>"
					dat += "<b>Penis Length:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_length;task=input'>[features["cock_length"]] inch(es)</a>"
					dat += "<b>Penis Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=cock_visibility;task=input'>[features["cock_visibility"]]</a>"
					dat += "<b>Has Testicles:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_balls'>[features["has_balls"] == TRUE ? "Yes" : "No"]</a>"
					if(features["has_balls"])
						if(!pref_species.use_skintones)
							dat += "<b>Testicles Type:</b> <a style='display:block;width:100px' href='?_src_=prefs;preference=balls_shape;task=input'>[features["balls_shape"]]</a>"
							dat += "<b>Testicles Color:</b></a><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: #[features["balls_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=balls_color;task=input'>Change</a><br>"
						dat += "<b>Testicles Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=balls_visibility;task=input'>[features["balls_visibility"]]</a>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Vagina</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_vag'>[features["has_vag"] == TRUE ? "Yes": "No" ]</a>"
				if(features["has_vag"])
					dat += "<b>Vagina Type:</b> <a style='display:block;width:100px' href='?_src_=prefs;preference=vag_shape;task=input'>[features["vag_shape"]]</a>"
					if(!pref_species.use_skintones)
						dat += "<b>Vagina Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: #[features["vag_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=vag_color;task=input'>Change</a><br>"
					dat += "<b>Vagina Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=vag_visibility;task=input'>[features["vag_visibility"]]</a>"
					dat += "<b>Has Womb:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_womb'>[features["has_womb"] == TRUE ? "Yes" : "No"]</a>"
				dat += "</td>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Breasts</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_breasts'>[features["has_breasts"] == TRUE ? "Yes" : "No" ]</a>"
				if(features["has_breasts"])
					if(!pref_species.use_skintones)
						dat += "<b>Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: #[features["breasts_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=breasts_color;task=input'>Change</a><br>"
					dat += "<b>Cup Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_size;task=input'>[features["breasts_size"]]</a>"
					dat += "<b>Breasts Shape:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_shape;task=input'>[features["breasts_shape"]]</a>"
					dat += "<b>Breasts Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=breasts_visibility;task=input'>[features["breasts_visibility"]]</a>"
					dat += "<b>Lactates:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_producing'>[features["breasts_producing"] == TRUE ? "Yes" : "No"]</a>"
				dat += "</td>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Belly</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_belly'>[features["has_belly"] == TRUE ? "Yes" : "No" ]</a>"
				if(features["has_belly"])
					if(!pref_species.use_skintones)
						dat += "<b>Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: #[features["belly_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=belly_color;task=input'>Change</a><br>"
					dat += "<b>Belly Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_size;task=input'>[features["belly_size"]]</a>"
					dat += "<b>Belly Shape:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=belly_shape;task=input'>[features["belly_shape"]]</a>"
					dat += "<b>Belly Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=belly_visibility;task=input'>[features["belly_visibility"]]</a>"
				dat += "</td>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Butt</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_butt'>[features["has_butt"] == TRUE ? "Yes" : "No"]</a>"
				if(features["has_butt"])
					if(!pref_species.use_skintones)
						dat += "<b>Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: #[features["butt_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=butt_color;task=input'>Change</a><br>"
					dat += "<b>Butt Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=butt_size;task=input'>[features["butt_size"]]</a>"
					dat += "<b>Butt Visibility:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=butt_visibility;task=input'>[features["butt_visibility"]]</a>"
				dat += "</td>"
			dat += "</td>"
			dat += "</tr></table>"*/




			//Right column
			// dat +="<td width='30%' valign='top'>"
			// // dat += "<h2>Profile Picture ([pfphost]):</h2><BR>"
			// // dat += "<b>Picture:</b> <a href='?_src_=prefs;preference=ProfilePicture;task=input'>[profilePicture ? "<img src=[PfpHostLink(profilePicture, pfphost)] width='125' height='auto' max-height='300'>" : "Upload a picture!"]</a><BR>"
			// dat += "<h2>Simple Creature Profile Picture ([creature_pfphost]):</h2><BR>"
			// dat += "<b>Picture:</b> <a href='?_src_=prefs;preference=CreatureProfilePicture;task=input'>[creature_profilepic ? "<img src=[PfpHostLink(creature_profilepic, creature_pfphost)] width='125' height='auto' max-height='300'>" : "Upload a picture!"]</a><BR>"
			// dat += "</td>"
			/*
			dat += "<b>Special Names:</b><BR>"
			var/old_group
			for(var/custom_name_id in GLOB.preferences_custom_names)
				var/namedata = GLOB.preferences_custom_names[custom_name_id]
				if(!old_group)
					old_group = namedata["group"]
				else if(old_group != namedata["group"])
					old_group = namedata["group"]
					dat += "<br>"
				dat += "<a href ='?_src_=prefs;preference=[custom_name_id];task=input'><b>[namedata["pref_name"]]:</b> [custom_names[custom_name_id]]</a> "
			dat += "<br><br>"

			Records disabled until a use for them is found
			dat += "<b>Custom job preferences:</b><BR>"
			dat += "<a href='?_src_=prefs;preference=ai_core_icon;task=input'><b>Preferred AI Core Display:</b> [preferred_ai_core_display]</a><br>"
			dat += "<a href='?_src_=prefs;preference=sec_dept;task=input'><b>Preferred Security Department:</b> [prefered_security_department]</a><BR></td>"
			dat += "<br>Records</b><br>"
			dat += "<br><a href='?_src_=prefs;preference=security_records;task=input'><b>Security Records</b></a><br>"
			if(length_char(security_records) <= 40)
				if(!length(security_records))
					dat += "\[...\]"
				else
					dat += "[security_records]"
			else
				dat += "[TextPreview(security_records)]...<BR>"

			dat += "<br><a href='?_src_=prefs;preference=medical_records;task=input'><b>Medical Records</b></a><br>"
			if(length_char(medical_records) <= 40)
				if(!length(medical_records))
					dat += "\[...\]<br>"
				else
					dat += "[medical_records]"
			else
				dat += "[TextPreview(medical_records)]...<BR>"
			dat += "<br><b>Hide ckey: <a href='?_src_=prefs;preference=hide_ckey;task=input'>[hide_ckey ? "Enabled" : "Disabled"]</b></a><br>"
			*/


	dat += "<a href='?_src_=prefs;preference=tab;tab=[CHAR_INFO_TAB]' [current_tab == CHAR_INFO_TAB ? "class='linkOn'" : ""]>Character Info</a>"






//

			dat +="<td width='25%' valign='top'>"
			dat += "<h2>Matchmaking preferences:</h2>"
			if(SSmatchmaking.initialized)
				for(var/datum/matchmaking_pref/match_pref as anything in SSmatchmaking.all_match_types)
					var/max_matches = initial(match_pref.max_matches)
					if(!max_matches)
						continue // Disabled.
					var/current_value = clamp((matchmaking_prefs[match_pref] || 0), 0, max_matches)
					var/set_name = !current_value ? "Disabled" : (max_matches == 1 ? "Enabled" : "[current_value]")
					dat += "<b>[initial(match_pref.pref_text)]:</b> <a href='?_src_=prefs;preference=set_matchmaking_pref;matchmake_type=[match_pref]'>[set_name]</a><br>"
			else
				dat += "<b>Loading matchmaking preferences...</b><br>"
				dat += "<b>Refresh once the game has finished setting up...</b><br>"
			dat += "</td>"






			dat += "<b>Top/Bottom/Switch:</b> <a href='?_src_=prefs;preference=tbs;task=input'>[tbs]</a><BR>"
			dat += "<b>Orientation:</b> <a href='?_src_=prefs;preference=kisser;task=input'>[kisser]</a><BR>"









/client/verb/set_tbs()
	set name = "Set Top/Bottom/Switch"
	set category = "Preferences"
	set desc = "Set whether you're a top, a bottom, or a switch!"

	var/new_tbs = input(src, "Are you a top, bottom, or switch? (or none of the above)", "Character Preference") as null|anything in TBS_LIST
	if(new_tbs)
		prefs.tbs = new_tbs
	SSstatpanels.cached_tops -= ckey
	SSstatpanels.cached_bottoms -= ckey
	SSstatpanels.cached_switches -= ckey
	switch(prefs.tbs)
		if(TBS_TOP)
			SSstatpanels.cached_tops |= ckey
		if(TBS_BOTTOM)
			SSstatpanels.cached_bottoms |= ckey
		if(TBS_SHOES)
			SSstatpanels.cached_switches |= ckey
	to_chat(src, "You can now proudly say '[span_boldnotice(new_tbs)]'.")
	prefs.save_preferences()

/client/verb/set_kiss()
	set name = "Set Kisser"
	set category = "Preferences"
	set desc = "Set whether you kiss boys, girls, or none of the above!!"

	var/new_kiss = input(src, "What sort of person do you like to kiss?", "Character Preference") as null|anything in KISS_LIST
	if(new_kiss)
		prefs.kisser = new_kiss
	SSstatpanels.cached_boykissers -= ckey
	SSstatpanels.cached_girlkissers -= ckey
	SSstatpanels.cached_anykissers -= ckey
	switch(prefs.kisser)
		if(KISS_BOYS)
			SSstatpanels.cached_boykissers |= ckey
		if(KISS_GIRLS)
			SSstatpanels.cached_girlkissers |= ckey
		if(KISS_ANY)
			SSstatpanels.cached_anykissers |= ckey
	to_chat(src, "You can now proudly say '[span_boldnotice(new_kiss)]'.")
	prefs.save_preferences()




//


				if("creature_name")
					var/new_name = input(user, "Choose your creature character's name:", "Character Preference")  as text|null
					if(new_name)
						new_name = reject_bad_name(new_name)
						if(new_name)
							creature_name = new_name
							if(isnewplayer(parent.mob)) // Update the player panel with the new name.
								var/mob/dead/new_player/player_mob = parent.mob
								player_mob.new_player_panel()
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")
				if("creature_species")
					if(!LAZYLEN(GLOB.creature_selectable))//Pokemon selection list is empty, so generate it.
						generate_selectable_creatures()
					if(!(creature_species in GLOB.creature_selectable))//Previously selected species which isn't supported anymore.
						creature_species = initial(creature_species)
					var/result = input(user, "Select a creature species", "Species Selection") as null|anything in GLOB.creature_selectable
					if(result)
						creature_species = result
						var/creature_type = GLOB.creature_selectable["[result]"]
						var/mob/living/M = new creature_type(user)
						if(creature_image)
							QDEL_NULL(creature_image)
						creature_image = image(icon=M.icon,icon_state=M.icon_state,dir=2)
						qdel(M)

				if("creature_flavor_text")
					var/msg = stripped_multiline_input(usr, "Set the examine text in your 'examine' verb.", "Flavor Text", html_decode(creature_flavor_text), MAX_FLAVOR_LEN, TRUE)
					if(!isnull(msg))
						creature_flavor_text = msg
				if("creature_ooc")
					var/msg = stripped_multiline_input(usr, "Set out of character notes related to roleplaying content preferences. THIS IS NOT FOR CHARACTER DESCRIPTIONS!", "OOC notes", html_decode(creature_ooc), MAX_FLAVOR_LEN, TRUE)
					if(!isnull(msg))
						creature_ooc = msg

				if("tbs")
					var/new_tbs = input(user, "Are you a top, bottom, or switch? (or none of the above)", "Character Preference") as null|anything in TBS_LIST
					if(new_tbs)
						tbs = new_tbs
				if("kisser")
					var/newkiss = input(user, "What sort of person do you like to kisser?", "Character Preference") as null|anything in KISS_LIST
					if(newkiss)
						kisser = newkiss
