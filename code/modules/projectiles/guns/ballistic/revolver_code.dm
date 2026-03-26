// In this document: Revolvers, Needlers, Weird revolvers
// See gun.dm for keywords and the system used for gun balance

/* 
 * WELCOME TO DAN'S REVAMPED REVOLVER THING, where something as simple as a revolver
 * becomes hopelessly complicated for both user and coder!
 * 
 * The 'chambered' round is whichever thing is loaded in the magazine at index 'chamber_index'
 * Normal actions advance the index in whichever direction the gun is set to rotate
 * Mousewheel can rotate the cylinder!
 * Middle-mouse half-cocks the gun, if supported
 * Alt-click ejects casings, if it can, in one of a few ways
 * - The round at the index offset defined by the gun's 'load_index_offset'
 *   - This is if its one of those single-load guns, like a single action army
 * - All the bullets in the gun just fly out, if its a break-action gun
 * - A special third option for revolvers that arent wierd and ancient
 *   - alt-click instead swngs out the cylinder, and you can either
 *   - click the gun to pop out the empties (or again to pop the rest)
 *   - insert a casing into the cylinder, prioritizing ones closest to the current chamber_index
 *   - use a box or other thing on the gun to continually load it and unload empties
 *   - use a speedloader to do all this, but faster
 * Some revolvers require you to be half-cocked to eject
 *   half-cock is a state on the hammer that most guns shouldnt be able to get to
 * Some revolvers require you to manually rotate the cylinder to eject a different casing
 * 
 * Most of the revolvers are sane and designed to be used by normal people
 * Some of the revolvers are not! this is intended for people who like fighting the game to do basic things
 * 
 * Also covers stuff like double barrel guns, cus why not
 * 
 * notes:
 * - There is no Halfcock state for the hammer!
 *   - not all revolvers and such have a halfcock, but all of them require some sort of jerking off to load
 *   - instead, loader_exposed is our half-cock state!
 * 
 * Revolver defaults to:
 * - double-action
 * - flip out ammo thing
 * - can rotate either way
 * 
 * todo:
 * - implement boxes / speedloaders automatically opening the gun
 *   - maybe with a delay since you didnt do it as intended
 * - implement an instruction manual to this nightmare of UX
 *   - a link in examine to blurt out a bunch of instruction
 * - a middle-mouse listener to open the thing
 * - make it need to be half-cocked to manually rotate (on guns that require it)
 *   - double actions and webleys or whatever can be worked with jerking the hammer off
 */

/obj/item/gun/ballistic/revolver
	name = "revolver template"
	desc = "should not exist."
	icon_state = "revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder
	casing_ejector = FALSE
	spawnwithmagazine = TRUE
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_recoil = HANDGUN_RECOIL(1, 1)
	init_firemodes = list(
		/datum/firemode/semi_auto
	)
	handedness = GUN_EJECTOR_ANY
	revolver = TRUE
	var/kind = REVKIND_SWINGOUT_DOUBLE_ACTION
	// which chamber is currently lined up with the barrel
	var/chamber_index = 1
	var/load_index_offset = 0 
	var/rotate_direction = REV_ADVANCE_FORWARD // defines for 1 or -1. see combat.dm
	/// is the cylinder out / action broken / half-cocked? mainly indicates the ammo is accessible and the shooting isnt
	var/loader_exposed = FALSE
	var/single_load = FALSE
	var/can_speedload = TRUE
	var/how_rotatable = REV_BOTH_ALWAYS
	var/eject_style = REV_EJECT_ADVANCED
	/* sounds! */
	var/rotate_forward_sound =       null
	var/rotate_backward_sound =      null
	var/cock_hammer_sound =          null
	var/uncock_hammer_sound =        null
	/// for when we put the gun into a state where we can access the ammo, like swinging out the cylinder or half-cocking
	var/open_gun_sound =             null
	/// for making it not accessible anymore
	var/close_gun_sound =            null
	var/insert_single_round_sound =  null
	var/eject_single_round_sound =   null
	var/speedloader_sound =          null
	var/eject_all_sound =            null
	/* flavor stuff! */
	var/flavor_mode = REV_FLAVOR_MODE_GENERIC
	var/datum/weakref/listening_to = null // for knowing whose mousewheels to listen to
	equipsound = 'sound/f13weapons/equipsounds/pistolequip.ogg'

/obj/item/gun/ballistic/revolver/Initialize()
	init_kind()
	. = ..()
	if(!istype(magazine, /obj/item/ammo_box/magazine/internal/cylinder))
		verbs += /obj/item/gun/ballistic/revolver/verb/spin

/obj/item/gun/ballistic/revolver/generate_guntags()
	..()
	gun_tags |= GUN_REVOLVER

/obj/item/gun/ballistic/revolver/equipped(mob/living/user, slot)
	. = ..()
	var/mob/listening_to_mob = GET_WEAKREF(listening_to)
	if(listening_to_mob)
		UnregisterSignal(listening_to_mob, COMSIG_MOB_MOUSEWHEEL)
		listening_to = null
	if(user.get_active_held_item() == src)
		listening_to = WEAKREF(user)
		RegisterSignal(user, COMSIG_MOB_MOUSEWHEEL, PROC_REF(mouse_wheel_signal_handler))

/obj/item/gun/ballistic/revolver/dropped(mob/user)
	. = ..()
	var/mob/listening_to_mob = GET_WEAKREF(listening_to)
	if(listening_to_mob)
		UnregisterSignal(listening_to_mob, COMSIG_MOB_MOUSEWHEEL)
		listening_to = null

/obj/item/gun/ballistic/revolver/proc/init_kind()
	switch(kind)
		if(REVKIND_SWINGOUT_DOUBLE_ACTION)
			single_load = FALSE
			can_speedload = TRUE
			how_rotatable = REV_BOTH_ALWAYS
			eject_style = REV_EJECT_ADVANCED
			load_index_offset = 0
		if(REVKIND_SINGLE_ACTION_REVOLVER)
			single_load = TRUE
			can_speedload = FALSE
			how_rotatable = REV_BOTH_HALFCOCK_ONLY
			eject_style = REV_EJECT_SINGLE
			load_index_offset = 3
		if(REVKIND_BREAK_ACTION_REVOLVER)
			single_load = FALSE
			can_speedload = TRUE
			how_rotatable = REV_ADVANCE_ONLY
			eject_style = REV_EJECT_ALL
			load_index_offset = 0
		if(REVKIND_BREAK_ACTION_SHOTGUN)
			single_load = FALSE
			can_speedload = TRUE
			how_rotatable = REV_BOTH_ALWAYS
			eject_style = REV_EJECT_ADVANCED
			load_index_offset = 0

/obj/item/gun/ballistic/revolver/proc/mouse_wheel_signal_handler(
	datum/source,
	mob/living/user,
	atom/A,
	delta_x,
	delta_y,
	params,
	)
	SIGNAL_HANDLER
	if(user != GET_WEAKREF(listening_to))
		return
	if(user.get_active_held_item() == src)
		advance_chamber(user, delta_y, TRUE)

/// When something scrollwheels while the mouse is on the gun
/// allows rotating it even if its not in your hand!
/obj/item/gun/ballistic/revolver/MouseWheel(delta_x,delta_y,location,control,params)
	// we have everything but who did it.
	// HOWEVER CAN WE FIGURE THIS OUT oh byond is based and has a way
	advance_chamber(usr, delta_y, TRUE)

/// does one of three things:
/// - if the gun is a single load one,  half-cocks the gun and allows you to load or eject from the single chamber
/// - if the gun is a break action, swings the cylinder open and sprays casings everywhere
/// - if the gun is a normal revolver, swings the cylinder open and waits for you to do things
/obj/item/gun/ballistic/revolver/MiddleClick(mob/living/doer)
	if(!can_interact_with_this(doer, TRUE, NONE))
		return
	toggle_loader_exposure(doer)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/gun/ballistic/revolver/AltClick(mob/living/doer)
	return MiddleClick(doer) // alt-click does the same thing as middle click, just for people who dont have a middle mouse button
	// also i couldnt figure something to do with the alt-click that middle-click wasnt already doing, so might as well

/obj/item/gun/ballistic/revolver/dont_shoot(mob/living/user)
	if(loader_exposed)
		// instead of shooting, try ejecting something!
		eject_casings(user, TRUE, TRUE, FALSE)
		update_icon()
		return
	. = ..()

/obj/item/gun/ballistic/revolver/get_chambered()
	if(!magazine)
		return null // shouldnt happen but just in case
	return LAZYACCESS(magazine.stored_ammo, chamber_index)

/obj/item/gun/ballistic/revolver/proc/get_chambered_at_load_index()
	if(!magazine)
		return null
	return LAZYACCESS(magazine.stored_ammo, get_load_offset_index())

// handled elsewhere
/obj/item/gun/ballistic/revolver/chamber_round()
	return get_chambered()

/// doer and direction are optional
/// direction can be 1 or -1, and if not provided it will just use the gun's default direction
/// doer just determines who gets the sound
/obj/item/gun/ballistic/revolver/proc/advance_chamber(mob/doer, direction, manually)
	if(!magazine)
		return
	if(manually && how_rotatable == REV_BOTH_HALFCOCK_ONLY && !loader_exposed)
		inform_user(doer, REV_ALERT_NEED_LOADER_EXPOSED_TO_ROTATE)
		return
	var/dir2moveit = rotate_direction
	if(direction)
		dir2moveit = direction
	chamber_index += dir2moveit
	if(manually && how_rotatable == REV_ADVANCE_ONLY && dir2moveit != rotate_direction)
		inform_user(doer, REV_ALERT_CAN_ONLY_ROTATE_IN_ADVANCE_DIRECTION)
		return
	if(chamber_index > magazine.capacity)
		chamber_index = 1
	else if(chamber_index < 1)
		chamber_index = magazine.capacity
	var/snd
	// if the rotated rotation is the same as the rotation defined for the gun, play the sound for that rotation.
	if(dir2moveit == rotate_direction)
		snd = rotate_forward_sound
	else
		snd = rotate_backward_sound
	if(doer)
		doer.playsound_local(doer, snd, 30, 1)
	else
		playsound(src, snd, 30, 1)

// finds which index is the one that we can load/unload from
// naturally, only relevant for single-load guns
/obj/item/gun/ballistic/revolver/proc/get_load_offset_index()
	if(!magazine)
		return null
	var/offset_index = chamber_index + load_index_offset
	if(offset_index > magazine.capacity)
		offset_index -= magazine.capacity
	else if(offset_index < 1)
		offset_index += magazine.capacity
	return offset_index

/// handles swinging the cylinder out / half-cocking the hammer, or closing it again
/obj/item/gun/ballistic/revolver/proc/toggle_loader_exposure(mob/doer)
	if(loader_exposed)
		close_gun(doer)
	else
		open_gun(doer)
	update_icon()

// opens the gun, allowing access to the ammo and whatnot
/obj/item/gun/ballistic/revolver/proc/open_gun(mob/doer, delay_the_thing)
	if(delay_the_thing)
		if(!cause_delay(doer, TRUE))
			return
	loader_exposed = TRUE
	playsound(doer, open_gun_sound, 30, 1)
	if(eject_style == REV_EJECT_ALL)
		auto_eject_casings(doer, TRUE)
	else
		inform_user(doer, REV_INFO_OPENED_GUN)

// closes the gun, making it ready to fire again
/obj/item/gun/ballistic/revolver/proc/close_gun(mob/doer, delay_the_thing)
	if(delay_the_thing)
		if(!cause_delay(doer, FALSE))
			return
	loader_exposed = FALSE
	hammer_state = GHAMMER_COCKED
	playsound(doer, close_gun_sound, 30, 1)
	inform_user(doer, REV_INFO_CLOSED_GUN)

/// happens when you do something to automatically trigger the gun to open or close
// such as using an ammo on it, without opening it manually
/obj/item/gun/ballistic/revolver/proc/cause_delay(mob/doer, opening)
	if(doing_something_with_guns(doer))
		to_chat(doer, span_warning("You're already doing something!"))
		return
	var/datum/weakref/loader = WEAKREF(doer)
	GLOB.currently_loading_something[loader] = world.time + (0.5 SECONDS)
	. = do_after(
		doer,
		delay = (0.5 SECONDS),
		needhand = TRUE,
		target = src,
		progress = TRUE,
		public_progbar = TRUE,
		allow_movement = TRUE,
		progbar_on_target = TRUE,
		)
	GLOB.currently_loading_something -= loader
	if(!.)
		to_chat(doer, span_alert("You were interrupted!"))

// ejects casings according to the gun's eject style!
/obj/item/gun/ballistic/revolver/proc/auto_eject_casings(mob/doer, do_words, do_sound, force_all_of_them)
	// indexes!
	if(!can_interact_with_this(doer, do_words, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	var/list/toeject = list()
	var/spew_everywhere = FALSE
	var/what_ejected = "empties"
	var/snd = eject_all_sound
	var/eject_how = eject_style
	if(force_all_of_them)
		eject_how = REV_EJECT_ALL
	var/obj/item/ammo_casing/singlebie
	switch(eject_how)
		if(REV_EJECT_SINGLE)
			var/lindex = get_load_offset_index()
			toeject |= lindex
			singlebie = LAZYACCESS(magazine.stored_ammo, lindex)
			snd = eject_single_round_sound
		if(REV_EJECT_ALL)
			for(var/i in 1 to magazine.capacity)
				toeject |= i
			var/spew_everywhere = TRUE
			what_ejected = "everything"
		if(REV_EJECT_ADVANCED)
			// eject empties first, then loadeds if there are no empties
			var/list/loaded = list()
			var/list/empties = list()
			for(var/i in 1 to magazine.capacity)
				var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, i)
				if(istype(CB, /obj/item/ammo_casing))
					if(CB.BB)
						loaded |= i
					else
						empties |= i
			if(LAZYLEN(empties))
				toeject |= empties
				what_ejected = "empties"
			else
				toeject |= loaded
				what_ejected = "loadeds"
	//nothing?
	if(!LAZYLEN(toeject))
		if(do_words)
			to_chat(doer, span_notice("There are no casings to eject!"))
		return
	for(var/i in toeject)
		var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, i)
		if(!istype(CB, /obj/item/ammo_casing))
			continue
		var/fling = spew_everywhere && !CB.BB
		eject_casing_at_index(doer, i, fling)
	update_icon()
	if(do_words)
		if(singlebie)
			inform_user(doer, REV_INFO_EJECTED_SINGLEBIE, singlebie)
		else if(eject_how == REV_EJECT_ALL)
			inform_user(doer, REV_INFO_EJECTED_ALL)
		else if(what_ejected == "empties")
			inform_user(doer, REV_INFO_EJECTED_EMPTIES)
		else if(what_ejected == "loadeds")
			inform_user(doer, REV_INFO_EJECTED_LOADEDS)
	if(do_sound)
		playsound(doer, snd, 30, 1)

/obj/item/gun/ballistic/revolver/proc/eject_casing_at_index(mob/doer, i, fling)
	if(!can_interact_with_this(doer, FALSE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, i)
	if(!istype(CB, /obj/item/ammo_casing))
		return
	CB.forceMove(drop_location())
	if(fling) // loadeds are a bit heavier, fling the rest everywhere
		var/randodir = pick(GLOB.alldirs)
		CB.bounce_away(FALSE, toss_direction = randodir)
	// chambered is handled by a proc, its auto-updated!
	magazine.stored_ammo[i] = null // eject a shell, it leaves a gap

/obj/item/gun/ballistic/revolver/proc/eject_specific_casing(mob/doer, obj/item/ammo_casing/CB, fling)
	if(!can_interact_with_this(doer, FALSE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	// find the casing and eject it, used for the alt-click-to-eject-a-specific-round style of revolver
	for(var/i in 1 to magazine.capacity)
		var/obj/item/ammo_casing/CB2 = LAZYACCESS(magazine.stored_ammo, i)
		if(CB2 == CB)
			eject_casing_at_index(doer, i, fling)
			return

/obj/item/gun/ballistic/revolver/proc/load_casing_at_index(mob/doer, obj/item/ammo_casing/CB, i)
	if(!can_interact_with_this(doer, FALSE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(istype(LAZYACCESS(magazine.stored_ammo, i), /obj/item/ammo_casing))
		return // shouldnt load on top of an existing round
	magazine.stored_ammo[i] = CB
	CB.forceMove(magazine)

/obj/item/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	advance_chamber()
	update_icon()

/obj/item/gun/ballistic/revolver/shoot_live_shot(mob/living/user as mob|obj)
	..()
	advance_chamber()
	update_icon()

/obj/item/gun/ballistic/revolver/attack_self(mob/living/user)
	if(loader_exposed)
		eject_casings(user, TRUE, TRUE, FALSE)
		update_icon()
		return
	toggle_hammer(user)
	update_icon()

/obj/item/gun/ballistic/revolver/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		return use_casing_on_gun(user, A)
	if(istype(A, /obj/item/ammo_box))
		return use_ammobox_on_gun(user, A)
	. = ..()

// the stuff before actually loading it into the gun
/obj/item/gun/ballistic/revolver/use_casing_on_gun(mob/user, obj/item/ammo_casing/A_casing)
	if(!can_interact_with_this(user, TRUE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(!room_in_gun_to_load_something())
		to_chat(user, span_warning("There is no room in [src] to load [A_casing]!"))
		return
	// does it fit?
	if(!magazine.does_that_fit_in_this(A_casing))
		to_chat(user, span_warning("[A_casing] doesn't fit in [src]!"))
		return
	if(!loader_exposed)
		open_gun(user, delay_the_thing = TRUE)
	insert_casing(A_casing, user)

/obj/item/gun/ballistic/revolver/use_ammobox_on_gun(mob/user, obj/item/ammo_box/A_box)
	if(!can_interact_with_this(user, TRUE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(!room_in_gun_to_load_something())
		to_chat(user, span_warning("There is no room in [src] to load anything in [A_box]!"))
		return
	var/can_load_something = FALSE
	for(var/obj/item/ammo_casing/bullet in A_box.stored_ammo)
		if(magazine.does_that_fit_in_this(bullet))
			can_load_something = TRUE
			break
	if(!can_load_something)
		to_chat(user, span_warning("[A_box] can't fit anything in [src]!"))
	if(!loader_exposed)
		open_gun(user, delay_the_thing = TRUE)
	insert_casings_from_box(user, A_box)

// single loaders just load one round, then stop
// otherwise, one of two things happens based on what the box is
// if it is a compatable speedloader for the gumagazine, and we accept speedloaders
//  - short delay, then all the rounds get loaded and empties get ejected with no extra delay
// otherwise, we just keep loading rounds one at a time until the box is empty or the gun is full
//  - with delays and sounds for each round
/obj/item/gun/ballistic/revolver/proc/insert_casings_from_box(mob/user, obj/item/ammo_box/A_box)
	if(!can_interact_with_this(user, TRUE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(!room_in_gun_to_load_something())
		return
	var/list/loadeds = list()
	// okay see if this thing is a speedloader
	var/speedload = FALSE
	if(can_speedload)
		var/datum/ammoholder_behavior/my_mag = magazine.get_load_behavior()
		speedload = my_mag.is_speedloader(A_box)
	if(speedload)
		cause_delay(user, TRUE)
		auto_eject_casings(user, FALSE, TRUE, TRUE)
	
	var/safety = 100 // just in case, to prevent infinite loops. should never happen unless something is very wrong
	while(safety--)
		if(!speedload && cause_delay(user, TRUE))
			break
		var/obj/item/ammo_casing/bullet = null
		for(var/obj/item/ammo_casing/candidate in A_box.stored_ammo)
			if(!candidate.BB) // only try to load live rounds, not empties
				continue
			if(!magazine.does_that_fit_in_this(candidate))
				continue
			bullet = candidate
			break
		if(!bullet)
			if(!LAZYLEN(loadeds))
				to_chat(user, span_warning("There is nothing in [A_box] that can fit in [src]!"))
			else
				to_chat(user, span_warning("[A_box] no longer has anything that can fit in [src]!"))
			break // nothing left to load!
		// load it somewhere!
		var/obj/item/ammo_casing/loaded_casing = insert_casing(user, bullet, !speedload, A_box)
		if(!istype(loaded_casing, /obj/item/ammo_casing))
			break // didnt load anything, so abort
		loadeds |= loaded_casing
		if(!speedload)
			advance_chamber(user)
	if(speedload)
		playsound(user, speedloader_sound, 30, 1)
	if(LAZYLEN(loadeds))
		//format "5x 9mm pingusbellend", "15x 9mm overpingus"
		var/list/loadnames = list()
		for(var/strng in loadeds)
			var/lcount = loadeds[strng]
			loadnames += "[lcount]x [strng]"
		var/what_i_loaded = english_list(loadnames)
		to_chat(user, span_green("Loaded [what_i_loaded]!"))
	else
		to_chat(user, span_alert("Couldn't load anything from [A_box]"))
		return FALSE
	update_icon()
	A_box.update_icon()
	return TRUE

/obj/item/gun/ballistic/revolver/proc/room_in_gun_to_load_something()
	for(var/i in 1 to magazine.capacity)
		var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, i)
		if(!istype(CB, /obj/item/ammo_casing))
			return TRUE
		if(!CB.BB)
			return TRUE
	return FALSE

// works differently based on the load style of the gun! generally tries to insert a casing somewhere it can go
// notably is only really different for single-load guns
/obj/item/gun/ballistic/revolver/proc/insert_casing(mob/user, obj/item/ammo_casing/A_casing, delay_the_thing, obj/item/ammo_box/camefrom)
	if(!can_interact_with_this(user, FALSE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(!magazine.does_that_fit_in_this(A_casing)) // another check to be safe
		to_chat(user, span_warning("[A_casing] doesn't fit in [src]!"))
		return
	if(single_load)
		var/lindex = get_load_offset_index()
		var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, lindex)
		if(istype(CB, /obj/item/ammo_casing))
			eject_casing_at_index(user, lindex, FALSE)
			playsound(user, eject_single_round_sound, 30, 1)
			if(!cause_delay(user, TRUE))
				return
		if(!can_interact_with_this(user, TRUE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
			return
		if(camefrom)
			camefrom.remove_casing(A_casing)
		load_casing_at_index(user, A_casing, lindex)
		playsound(user, insert_single_round_sound, 30, 1)
		inform_user(user, REV_INFO_LOADED_SINGLE, A_casing)
		return A_casing
	var/index_offset = chamber_index // this way if the chamber index is 5 and the gun capacity is 6, it checks in this order: 5, 6, 1, 2, 3, 4
	// they also can rotate in two directions, so we can check in the opposite direction as well if its set to rotate backwards
	var/list/check_order = list()
	for(var/i in 1 to magazine.capacity)
		// for an index of 4 on a 6 capacity gun
		// would output for forward rotation: 4, 5, 6, 1, 2, 3
		// and for backward rotation: 4, 3, 2, 1, 6, 5
		var/real_index = index_offset + (i * rotate_direction)
		if(real_index > magazine.capacity)
			real_index -= magazine.capacity
		else if(real_index < 1)
			real_index += magazine.capacity
		check_order |= real_index
	var/bestslot = 1
	var/obj/item/ammo_casing/casing_at_bestslot
	// try to load the slot at the shoot index first, then wrap around from there
	// lower indexes in the check order are prioritized over higher ones
	for(var/i in 1 to LAZYLEN(check_order))
		var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, LAZYACCESS(check_order, i))
		if(!istype(CB, /obj/item/ammo_casing)) // empty slot, probably
			bestslot = LAZYACCESS(check_order, i)
			break
		else if(!CB.BB) // if its an empty casing, prioritize it for loading over loaded slots, since it frees up space
			bestslot = LAZYACCESS(check_order, i)
			casing_at_bestslot = CB
			break
	if(istype(casing_at_bestslot, /obj/item/ammo_casing))
		cause_delay(user, TRUE)
		eject_casing_at_index(user, bestslot, FALSE)
		playsound(user, eject_single_round_sound, 30, 1)
	if(!can_interact_with_this(user, TRUE, REV_FLAG_NEEDS_MAGAZINE | REV_FLAG_NEEDS_LOADER_EXPOSED))
		return
	if(camefrom)
		camefrom.remove_casing(A_casing)
	load_casing_at_index(user, A_casing, bestslot)
	playsound(user, insert_single_round_sound, 30, 1)
	inform_user(user, REV_INFO_LOADED_SINGLE, A_casing)
	return A_casing

/obj/item/gun/ballistic/revolver/proc/can_interact_with_this(mob/living/user, do_words, inter_flags = NONE)
	if(user.incapacitated(allow_crit = TRUE))
		if(do_words)
			to_chat(user, span_warning("You're way too messed up to muck with [src]!"))
		return FALSE
	if(!Adjacent(user))
		if(do_words)
			to_chat(user, span_warning("You need to be closer to [src] to muck with it!"))
		return FALSE
	if((inter_flags & REV_FLAG_NEEDS_MAGAZINE) && !magazine)
		if(do_words)
			to_chat(user, span_warning("[src] doesn't have a magazine!"))
		return FALSE
	if((inter_flags & REV_FLAG_NEEDS_LOADER_EXPOSED) && !loader_exposed)
		if(do_words)
			inform_user(user, REV_ALERT_NEED_LOADER_EXPOSED_TO_DO_THAT)
		return FALSE
	if(doing_something_with_guns(user))
		if(do_words)
			to_chat(user, span_warning("You're already doing something!"))
		return FALSE
	return TRUE

/obj/item/gun/ballistic/revolver/toggle_hammer(mob/living/user)
	if(loader_exposed)
		return
	switch(hammer_state)
		if(GHAMMER_UNCOCKED)
			hammer_state = GHAMMER_COCKED
		if(GHAMMER_COCKED)
			hammer_state = GHAMMER_UNCOCKED
	var/snd = hammer_state == GHAMMER_COCKED ? cock_hammer_sound : uncock_hammer_sound
	playsound(user, snd, 30, 1)

/obj/item/gun/ballistic/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if(do_spin())
		M.visible_message("[M] spins [src]'s chamber.", span_notice("You spin [src]'s chamber."))
		playsound(src, 'sound/f13weapons/revolverspin.ogg', 30, 1)
	else
		verbs -= /obj/item/gun/ballistic/revolver/verb/spin

/obj/item/gun/ballistic/revolver/proc/do_spin()
	chamber_index = rand(1, magazine.capacity)

/obj/item/gun/ballistic/revolver/can_shoot()
	if(loader_exposed)
		return FALSE
	. = ..()

/obj/item/gun/ballistic/revolver/examine(mob/user)
	. = ..()
	. += get_ammo_readout()


// welcome to a cool readout of what's in ur gun!
/obj/item/gun/ballistic/revolver/proc/get_ammo_readout()
	. = ""
	if(!magazine)
		. = "The gun is empty on a very deep buggy level."
		return
	var/load_offset = get_load_offset_index()
	var/shots_left = 0
	var/chambered_is_loaded = FALSE
	for(var/i in 1 to magazine.capacity)
		var/blt = ""
		var/obj/item/ammo_casing/CB = LAZYACCESS(magazine.stored_ammo, i)
		var/color = "white"
		if(istype(CB, /obj/item/ammo_casing))
			if(CB.BB)
				blt = "█"
				color = "teal"
				shots_left++
				if(i == chamber_index)
					chambered_is_loaded = TRUE
			else
				blt = "▄"
				color = "purple"
		else
			blt = "░"
			color = "white"
		if(i == chamber_index)
			blt = "\[" + blt + "\]"
		if(eject_style == REV_EJECT_SINGLE && i == load_offset)
			blt = "(" + blt + ")"
		blt += "<span style='color:[color]'>[blt]</span>"
		. += blt
	// the number readout
	var/shots_color = shots_left > 0 ? "teal" : "red"
	. += "\n"
	. += " <span style='color:[shots_color]'>[shots_left]</span> / [span_notice(magazine.capacity)] shots left."
	if(chambered_is_loaded)
		. += "\n"
		. += "The chambered round is [span_good("loaded and ready to fire!")]"
	// and some help on how to read the damn thing
	. += "\n"
	. += "\[ \] - Chambered round"
	if(eject_style == REV_EJECT_SINGLE)
		. += ", ( ) - Round that can be ejected."



/obj/item/gun/ballistic/revolver/debug
	name = "Debug Revolver"
	desc = "This is a really cool gun! Its here to test revolvery things! Dan is cool!"
	icon_state = "357colt"
	inhand_icon_state = "357colt"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev357
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	fire_sound = 'sound/f13weapons/357magnum.ogg'
	kind = REVKIND_SWINGOUT_DOUBLE_ACTION
	rotate_forward_sound =       'sound/effects/bamf.ogg'
	rotate_backward_sound =      'sound/effects/alert.ogg'
	cock_hammer_sound =          'sound/effects/bang.ogg'
	uncock_hammer_sound =        'sound/effects/beeper7.ogg'
	open_gun_sound =             'sound/effects/bin_open.ogg'
	close_gun_sound =            'sound/effects/bin_close.ogg'
	insert_single_round_sound =  'sound/effects/bleeblee.ogg'
	eject_single_round_sound =   'sound/effects/body_fall_over_dead.ogg'
	speedloader_sound =          'sound/effects/boowomp.ogg'
	eject_all_sound =            'sound/effects/break_stone.ogg'
	flavor_mode = REV_FLAVOR_MODE_GENERIC

/obj/item/gun/ballistic/revolver/debug/single_action
	name = "Debug Single-Action Revolver"
	desc = "This is a single action gun that demonstrates the single-load style of revolver. Fuzzy's got a cute butt!"
	kind = REVKIND_SINGLE_ACTION_REVOLVER

/obj/item/gun/ballistic/revolver/debug/break_action
	name = "Debug Break-Action Revolver"
	desc = "This is a break-action gun that demonstrates the break-action style of revolver. Fenny is very stank!"
	kind = REVKIND_BREAK_ACTION_REVOLVER












