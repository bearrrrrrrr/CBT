/// List of weakrefs to mobs performing ammo loading, and the time they last started doing it
/// format: WEAKREF(bingus) = 3121415
GLOBAL_LIST_EMPTY(currently_loading_something)

//Boxes of ammo
/obj/item/ammo_box
	name = "ammo box (null_reference_exception)"
	desc = "A box of ammo."
	icon = 'icons/obj/ammo.dmi'
	flags_1 = CONDUCT_1
	slot_flags = INV_SLOTBIT_BELT
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	custom_materials = list(/datum/material/iron = 30000)
	throwforce = 2
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	var/list/stored_ammo = list()
	var/obj/item/ammo_casing/ammo_type = /obj/item/ammo_casing
	var/max_ammo = 7
	var/multiple_sprites = 0
	/// Anything on the list can be added to this magazine. MUST be a list
	var/list/caliber = list()
	var/replace_spent_rounds = 0
	var/multiload = TRUE
	var/fixed_mag = FALSE
	/// Can this magazine have its caliber changed?
	var/can_change_caliber = FALSE
	var/caliber_change_step = MAGAZINE_CALIBER_CHANGE_STEP_0
	/// What valid calibers can this magazine be changed to?
	var/list/valid_new_calibers
	/// If its been rebored, dont add any more rebored to its everything
	var/been_rebored = FALSE
	var/start_empty = FALSE
	var/list/bullet_cost
	var/list/base_cost// override this one as well if you override bullet_cost
	var/start_ammo_count
	var/randomize_ammo_count = FALSE //am evil~ --too evil
	var/supposedly_a_problem = 0
	maptext_width = 48 //prevents ammo count from wrapping down into two lines
	var/casing_insert_time = (0.5 SECONDS)
	var/load_into_gun_time = (1 SECONDS)
	var/can_remove_casings = TRUE
	var/can_accept_casings = TRUE // for mags that cannot have ammo loaded back into them
	var/accepted_speedloader = SPEEDLOADER_CLIP
	var/speedloader_kind = NONE

/obj/item/ammo_box/Initialize(mapload, ...)
	. = ..()
	init_ammo()
	if(!islist(caliber))
		caliber = list()
	if(length(caliber) < 1)
		if(ammo_type)
			caliber += initial(ammo_type.caliber)
		else
			caliber += CALIBER_ANY // default to accepting any old caliber
	update_icon()

/obj/item/ammo_box/Destroy()
	QDEL_LIST(stored_ammo)
	return ..() 

/obj/item/ammo_box/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_POST_ADMIN_SPAWN,PROC_REF(admin_load))
	RegisterSignal(src, COMSIG_GUN_MAG_ADMIN_RELOAD,PROC_REF(admin_load))

/// Updates the ammo count number that renders on top of the icon
/obj/item/ammo_box/proc/UpdateAmmoCountOverlay()
	return // fenny said no

	// if(isturf(loc))//Only show th ammo count if the magazine is, like, in an inventory or something. Mags on the ground don't need a big number on them, that's ugly.
	// 	maptext = ""
	// else 
	// 	if(LAZYLEN(stored_ammo) > 0)
	// 		maptext = "<b>[LAZYLEN(stored_ammo)]/[max_ammo]"
	// 	else
	// 		maptext = "<b>0/[max_ammo]"

// /obj/item/ammo_box/doMove(atom/destination)
// 	. = ..()
// 	UpdateAmmoCountOverlay()

/// An aheal, but for ammo boxes
/obj/item/ammo_box/proc/admin_load()
	if(!ammo_type)
		return
	. = fill_magazine(max_ammo, TRUE)
	update_icon()

/obj/item/ammo_box/proc/init_ammo()
	if(start_empty)
		return // All done!
	if(!ammo_type)
		return // No ammo type, no ammo
	var/num_bullets = max_ammo
	if(start_ammo_count)
		num_bullets = min(start_ammo_count, max_ammo)
	if(randomize_ammo_count)
		num_bullets = get_random_bullet_amount(num_bullets)
	fill_magazine(num_bullets)

/obj/item/ammo_box/proc/get_random_bullet_amount(num_bullets = max_ammo)
	var/amount = pick(0, rand(0, num_bullets), num_bullets)
	return amount

/obj/item/ammo_box/proc/fill_magazine(num_bullets = max_ammo, cock)
	var/to_load = clamp(num_bullets, 0, max(0, max_ammo - LAZYLEN(stored_ammo)))
	if(to_load < 1)
		return
	. = to_load
	for(var/i in 1 to to_load)
		stored_ammo += new ammo_type(src)
	if(cock && istype(loc, /obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/my_gun = loc
		if(my_gun?.chambered?.BB)
			return
		my_gun?.chamber_round()

/obj/item/ammo_box/proc/get_round(keep = 0)
	if (!stored_ammo.len)
		return null
	else
		var/b = stored_ammo[stored_ammo.len]
		stored_ammo -= b
		if (keep)
			stored_ammo.Insert(1,b)
		return b

/obj/item/ammo_box/proc/does_that_fit_in_this(obj/item/ammo_casing/other_casing)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if(!istype(other_casing, /obj/item/ammo_casing))
		return FALSE
	if(!islist(caliber) && other_casing.type != ammo_type) // ALWAYS use a caliber ffs
		return FALSE
	if(!(other_casing.caliber in caliber))
		if(!(CALIBER_ANY in caliber))
			return FALSE
	return TRUE

// check if WE can accept an ammo from OTHER_BOX
/obj/item/ammo_box/proc/get_something_that_could_fit_in_this(obj/item/ammo_box/other_box)
	for(var/obj/item/ammo_casing/ammo in other_box.stored_ammo)
		if(does_that_fit_in_this(ammo))
			return ammo

/obj/item/ammo_box/proc/give_round(obj/item/ammo_casing/other_casing, replace_spent = 0)
	if (!does_that_fit_in_this(other_casing))
		return FALSE
	
	if(length(stored_ammo) < max_ammo) // found an empty slot, stuff it in!
		insert_round(other_casing)
		return TRUE

	for(var/i in 1 to length(stored_ammo)) // revolvers are tricky, try and stuff in a shell in an empty slot
		var/obj/item/ammo_casing/bullet = stored_ammo[i]
		if(!bullet || isnull(bullet))
			insert_round(other_casing, i) // pop it in
			return TRUE

	if(replace_spent)
		for(var/i in 1 to length(stored_ammo)) // mag is full, check for empties
			var/obj/item/ammo_casing/bullet = stored_ammo[i]
			if(bullet.BB) // Found a bullet, but its empty!)
				continue
			eject_round(bullet, i) // pop it out
			insert_round(other_casing, i) // pop it in
			return TRUE
	return FALSE

/obj/item/ammo_box/proc/eject_round(obj/item/ammo_casing/casing_to_eject, index)
	if(!istype(casing_to_eject, /obj/item/ammo_casing))
		return
	if(index)
		stored_ammo[index] = null
	casing_to_eject.forceMove(get_turf(src.loc))

/obj/item/ammo_box/proc/insert_round(obj/item/ammo_casing/other_casing, index)
	if(!istype(other_casing))
		return FALSE
	if(index) // For revolvers
		stored_ammo[index] = other_casing // Carefully replace the spent round
		. = TRUE
	else
		stored_ammo += other_casing // just stuff it in there
		. = TRUE
	if(.)
		other_casing.forceMove(src)

/obj/item/ammo_box/proc/can_load(mob/user, verbose)
	if(LAZYLEN(stored_ammo) >= max_ammo)
		if(verbose)
			to_chat(user, span_alert("[src] is full!"))
		return FALSE // its full!
	if(!can_accept_casings)
		if(verbose)
			to_chat(user, span_alert("[src] can't be reloaded!"))
		return FALSE // doesnt accept ammo being added!
	if(get_dist(get_turf(src), get_turf(user)) > 1)
		if(verbose)
			to_chat(user, span_alert("You're too far away from [src], get closer!"))
		return FALSE // too far away
	return check_loading(user, verbose)
	// check the cooldowns or something

/obj/item/ammo_box/proc/can_unload(mob/user, verbose)
	if(LAZYLEN(stored_ammo) <= 0)
		if(verbose)
			to_chat(user, span_alert("[src] is empty!"))
		return FALSE // its full!
	if(!can_remove_casings)
		if(verbose)
			to_chat(user, span_alert("[src] can't be unloaded!"))
		return FALSE // doesnt accept ammo being added!
	if(get_dist(get_turf(src), get_turf(user)) > 1)
		if(verbose)
			to_chat(user, span_alert("You're too far away from [src], get closer!"))
		return FALSE // too far away
	return check_loading(user, verbose)

/obj/item/ammo_box/proc/check_loading(mob/user, verbose)
	var/datum/weakref/them = WEAKREF(user)
	if (!GLOB.currently_loading_something[them])
		return TRUE
	if (GLOB.currently_loading_something[them] < world.time)
		GLOB.currently_loading_something -= them
		return TRUE
	if (GLOB.currently_loading_something[them] >= world.time)
		if(verbose)
			to_chat(user, span_alert("You're already loading something!"))
		return FALSE
	return TRUE

/obj/item/ammo_box/attackby(obj/item/A, mob/user, params)
	. = ..()
	if(istype(A, /obj/item/ammo_casing/))
		if(load_from_casing(A, user, TRUE, TRUE, FALSE))
			return TRUE
	if(istype(A, /obj/item/ammo_box/))
		if(load_from_box(A, user, TRUE))
			return TRUE
	// if(COOLDOWN_FINISHED(src, supposedly_a_problem) && istype(A, /obj/item/gun))
	// 	COOLDOWN_START(src, supposedly_a_problem, 1) // just a brief thing so that the game has time to load the thing before you try to load the thing again, thanks automatics
	// 	return A.attackby(src, user, params, silent, replace_spent)

/obj/item/ammo_box/proc/load_from_box(obj/item/ammo_box/other_ammobox, mob/user, verbose)
	if(!istype(other_ammobox, /obj/item/ammo_box))
		return FALSE
	if(!can_load(user, TRUE))
		return FALSE
	if(!other_ammobox.can_unload(user, TRUE))
		return FALSE
	// format: "9mm pingusbellend" = 1
	var/list/loaded = list()

	var/speedload = CHECK_BITFIELD(accepted_speedloader, other_ammobox.speedloader_kind)
	if(speedload) // kinda ironic that speedloading has a do-after
		if(!load_delay(user))
			return FALSE

	// main load loop
	var/safety = 200
	while(transfer_casing_in(other_ammobox, user, verbose, speedload, loaded) && (safety-- > 0))
		continue

	// finish up
	if(LAZYLEN(loaded))
		//format "5x 9mm pingusbellend", "15x 9mm overpingus"
		var/list/loadnames = list()
		for(var/strng in loaded)
			var/lcount = loaded[strng]
			loadnames += "[lcount]x [strng]"
		var/what_i_loaded = english_list(loadnames)
		to_chat(user, span_green("Loaded [what_i_loaded]!"))
	else
		if(verbose)
			to_chat(user, span_alert("Couldn't load anything from [other_ammobox]"))
		return FALSE
	other_ammobox.update_icon()
	update_icon()
	if(speedload) // sound didnt happen, do it here
		playsound(src, 'sound/weapons/bulletinsert.ogg', 60, 1)
	return TRUE

// transfer one single round from an ammobox to this ammobox
// returns bool, loaded is optional... sorta
/obj/item/ammo_box/proc/transfer_casing_in(obj/item/ammo_box/other_box, mob/user, verbose, speedload, list/loaded)
	// can both boxes share ammo?
	if(!can_load(user, TRUE))
		return FALSE
	if(!other_box.can_unload(user, TRUE))
		return FALSE
	
	// find an ammo to take from it to us
	var/obj/item/ammo_casing/ammo = get_something_that_could_fit_in_this(other_box)
	if(!ammo)
		if(verbose)
			to_chat(user, "[other_box] doesn't have anything that fits in this!")
		return FALSE
	
	var/l_dosound = !speedload
	// have an ammo, do the transfer dance
	if(!load_from_casing(ammo, user, l_dosound, FALSE, speedload))
		return FALSE
	if(islist(loaded))
		var/loadname = ammo.name
		if(!loaded[loadname])
			loaded[loadname] = 0
		loaded[loadname]++
	// it moved, remove it from the other box
	other_box.remove_casing(ammo)
	other_box.update_icon()
	update_icon()
	return TRUE

// proc so that revolvers can do their thing right
/obj/item/ammo_box/proc/remove_casing(obj/item/ammo_casing/other_casing)
	stored_ammo -= other_casing

/obj/item/ammo_box/proc/load_delay(mob/user)
	var/datum/weakref/loader = WEAKREF(user)
	GLOB.currently_loading_something[loader] = world.time + (casing_insert_time)
	. = do_after(
		user,
		delay = casing_insert_time,
		needhand = TRUE,
		target = src,
		progress = TRUE,
		public_progbar = TRUE
		)
	GLOB.currently_loading_something -= loader
	if(!.)
		to_chat(user, span_alert("You were interrupted!"))

/obj/item/ammo_box/proc/load_into_gun_delay(mob/user)
	var/datum/weakref/loader = WEAKREF(user)
	GLOB.currently_loading_something[loader] = world.time + (load_into_gun_time)
	. = do_after(
		user,
		delay = load_into_gun_time,
		needhand = TRUE,
		target = src,
		progress = TRUE,
		public_progbar = TRUE
		)
	GLOB.currently_loading_something -= loader
	if(!.)
		to_chat(user, span_alert("You were interrupted!"))

/obj/item/ammo_box/proc/load_from_casing(obj/item/ammo_casing/other_casing, mob/user, dosound, dotext, bypass_doafter)
	if(!can_load(user, dotext))
		return FALSE
	if(!does_that_fit_in_this(other_casing))
		if(dotext)
			to_chat(user, span_alert("[other_casing] doesn't fit in this!"))
		return FALSE
	if(!bypass_doafter)
		if(!load_delay(user))
			return FALSE
	if(!give_round(other_casing, replace_spent_rounds))
		if(dotext)
			to_chat(user, span_alert("You couldn't get [other_casing] in there!"))
		return FALSE
	// success!
	user.transferItemToLoc(other_casing, src, TRUE)
	if(dosound)
		playsound(src, 'sound/weapons/bulletinsert.ogg', 60, 1)
	if(dotext)
		to_chat(user, span_green("Loaded \a [other_casing] into [src]!"))
	other_casing.update_icon()
	update_icon()

/obj/item/ammo_box/attack_self(mob/user)
	pop_casing(user)

/obj/item/ammo_box/proc/pop_casing(mob/user, to_ground, silent)
	if(!can_remove_casings)
		to_chat(user, span_notice("You can't remove ammo from \the [src]!"))
		return FALSE
	var/obj/item/ammo_casing/A = get_round()
	if(!A)
		to_chat(user, span_alert("There's nothing in \the [src]!"))
		return FALSE
	if(to_ground || !user.put_in_hands(A))
		A.bounce_away(FALSE, NONE)
	playsound(src, 'sound/weapons/bulletinsert.ogg', 60, 1)
	if(!silent)
		to_chat(user, span_notice("You remove \a [A] from \the [src]!"))
	update_icon()
	return A

/obj/item/ammo_box/update_icon()
	. = ..()
	// UpdateAmmoCountOverlay()
/* 	if(length(bullet_cost))
		var/temp_materials = custom_materials.Copy()
		for (var/material in bullet_cost)
			var/material_amount = bullet_cost[material]
			material_amount = (material_amount*stored_ammo.len) + base_cost[material]
			temp_materials[material] = material_amount
		set_custom_materials(temp_materials) */

/obj/item/ammo_box/examine(mob/user)
	. = ..()
	if(islist(caliber))
		. += "This accepts [span_notice(english_list(caliber))]!"
	if(length(stored_ammo))
		. += "There [length(stored_ammo) == 1 ? "is" : "are"] [span_notice("[length(stored_ammo)]")] shell\s left!"

/obj/item/ammo_box/update_icon_state()
	switch(multiple_sprites)
		if(1) //standard
			icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(2) //speedloaders and such
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo]" : "0"]"
		if(3) //improvised bags
			if(stored_ammo.len >= 8)
				icon_state = "[initial(icon_state)]-8"
			else
				icon_state = "[initial(icon_state)]-[stored_ammo.len]"
		if(4) //ammo crates
			if(stored_ammo.len >= 100)
				icon_state = "[initial(icon_state)]-5"
			else if(stored_ammo.len >= 75)
				icon_state = "[initial(icon_state)]-4"
			else if(stored_ammo.len >= 50)
				icon_state = "[initial(icon_state)]-3"
			else if(stored_ammo.len >= 25)
				icon_state = "[initial(icon_state)]-2"
			else if(stored_ammo.len >= 1)
				icon_state = "[initial(icon_state)]-1"
			else
				icon_state = "[initial(icon_state)]-0"
		if(5)
			if(stored_ammo.len >= 12)
				icon_state = "[initial(icon_state)]-12"
			else
				icon_state = "[initial(icon_state)]-[stored_ammo.len]"
	// UpdateAmmoCountOverlay()

//Behavior for magazines
/obj/item/ammo_box/magazine/proc/ammo_count()
	return stored_ammo.len

/obj/item/ammo_box/magazine/proc/empty_magazine()
	var/turf_mag = get_turf(src)
	for(var/obj/item/ammo in stored_ammo)
		ammo.forceMove(turf_mag)
		stored_ammo -= ammo
	update_icon()
	// UpdateAmmoCountOverlay()

/obj/item/ammo_box/magazine/handle_atom_del(atom/A)
	stored_ammo -= A
	update_icon()
