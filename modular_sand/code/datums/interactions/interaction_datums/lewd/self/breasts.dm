/datum/interaction/lewd/titgrope_self
	description = "Self/Body - Grope your own breasts."
	require_user_hands = TRUE
	require_user_breasts = REQUIRE_ANY
	is_self_action = TRUE
	max_distance = 0
	write_log_user = "groped own breasts"
	write_log_target = null
	user_required_parts = list(
		MERPNEED_ARM
	)
	target_required_parts = list(
		MERPNEED_BREASTS
	)

	help_messages = list(
		"XU_NAME gently gropes XU_THEIR breast",
		"XU_NAME softly squeezes XU_THEIR breasts",
		"XU_NAME grips XU_THEIR breasts",
		"XU_NAME runs a few fingers over XU_THEIR breast",
		"XU_NAME delicately teases XU_THEIR nipple",
		"XU_NAME traces a touch across XU_THEIR breast"
	)
	// disarm_messages = list("XU_NAME is really rubbing at XU_THEIR own rear end.") // leaving thease out mean that
	// grab_messages = list("XU_NAME is rubbing XU_THEIR backside pretty aggressively!") // all but harm will do the help words!!!
	harm_messages = list(
		"XU_NAME aggressively gropes XU_THEIR breast",
		"XU_NAME grabs XU_THEIR breasts",
		"XU_NAME tightly squeezes XU_THEIR breasts",
		"XU_NAME slaps at XU_THEIR breasts",
		"XU_NAME gropes XU_THEIR breasts roughly"
	)

	simple_sounds = list('sound/weapons/thudswoosh.ogg') // frumf, frumf
	user_lust_mult = 1.0 // this ONE trick will make you cum in 5 seconds! doctors hate it!
	lust_go_to = LUST_USER | LUST_TARGET

/datum/interaction/lewd/self_nipsuck
	description = "Self/Body - Suck your own nips."
	require_user_breasts = REQUIRE_ANY
	require_user_mouth = TRUE
	is_self_action = TRUE
	simple_sounds = null
	max_distance = 0
	write_log_user = "sucked their own nips"
	write_log_target = null
	simple_messages = list(
		"XU_NAME brings XU_THEIR own milk tanks to XU_THEIR mouth and sucks deeply into them",
		"XU_NAME takes a big sip of XU_THEIR own fresh milk",
		"XU_NAME fills XU_THEIR own mouth with a big gulp of XU_THEIR warm milk"
	)
	user_lust_mult = 1
	lust_go_to = LUST_USER | LUST_TARGET
	user_required_parts = list(
		
	)
	target_required_parts = list(
		MERPNEED_BREASTS
	)

