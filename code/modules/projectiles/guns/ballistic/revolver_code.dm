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
	// which chamber is currently lined up with the barrel
	var/chamber_index = 1
	var/load_index_offset = 3
	var/rotate_direction = REV_ADVANCE_FORWARD // defines for 1 or -1. see combat.dm
	var/swung = FALSE // has the cylinder been swung out? only used for revolvers that require it to eject
	var/load_style = REV_SWING_OUT // how the gun handles loading and ejecting, see combat.dm for details
	/* sounds! */
	var/rotate_forward_sound =       'sound/weapons/biblically_accurate_revolver/revolveradvance.ogg'
	var/rotate_backward_sound =      'sound/weapons/biblically_accurate_revolver/revolveradvance_reverse.ogg'
	/// for when we put the gun into a state where we can access the ammo, like swinging out the cylinder or half-cocking
	var/open_gun_sound =             'sound/weapons/biblically_accurate_revolver/revolveropenswing.ogg'
	/// for making it not accessible anymore
	var/close_gun_sound =            'sound/weapons/biblically_accurate_revolver/revolvercloseswing.ogg'
	var/insert_single_round_sound =  'sound/weapons/biblically_accurate_revolver/revolverload.ogg'
	var/eject_single_round_sound =   'sound/weapons/biblically_accurate_revolver/revolverunload.ogg'
	var/speedloader_sound =          'sound/weapons/biblically_accurate_revolver/revolverspeedloader.ogg'
	var/eject_all_sound =            'sound/weapons/biblically_accurate_revolver/revolvereject.ogg'
	/* flavor stuff! */
	var/open_flavor_mode = REV_FLAVOR_OPEN_GENERIC
	var/close_flavor_mode = REV_FLAVOR_CLOSE_GENERIC
	var/datum/weakref/listening_to = null // for knowing whose mousewheels to listen to
	equipsound = 'sound/f13weapons/equipsounds/pistolequip.ogg'

/obj/item/gun/ballistic/revolver/Initialize()
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
		advance_chamber(user, delta_y)

/// When something scrollwheels while the mouse is on the gun
/// allows rotating it even if its not in your hand!
/obj/item/gun/ballistic/revolver/MouseWheel(delta_x,delta_y,location,control,params)
	// we have everything but who did it.
	// HOWEVER CAN WE FIGURE THIS OUT oh byond is based and has a way
	advance_chamber(usr, delta_y)

/// does one of three things:
/// - if the gun is a single load one,  half-cocks the gun and allows you to load or eject from the single chamber
/// - if the gun is a break action, swings the cylinder open and sprays casings everywhere
/// - if the gun is a normal revolver, swings the cylinder open and waits for you to do things
/obj/item/gun/ballistic/revolver/MiddleClick(mob/living/doer)
	if(!isliving(doer))
		return
	if(!Adjacent(user))
		return
	if(doer.incapacitated(allow_crit = TRUE))
		return
	handle_swing(doer)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/gun/ballistic/revolver/get_chambered()
	if(!magazine)
		return null // shouldnt happen but just in case
	return LAZYACCESS(magazine.stored_ammo, chamber_index)

// handled elsewhere
/obj/item/gun/ballistic/revolver/chamber_round()
	return get_chambered()

/// doer and direction are optional
/// direction can be 1 or -1, and if not provided it will just use the gun's default direction
/// doer just determines who gets the sound
/obj/item/gun/ballistic/revolver/proc/advance_chamber(mob/doer, direction)
	if(!magazine)
		return
	var/dir2moveit = rotate_direction
	if(direction)
		dir2moveit = direction
	chamber_index += dir2moveit
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

/obj/item/gun/ballistic/revolver/shoot_with_empty_chamber(mob/living/user as mob|obj)
	..()
	advance_chamber()
	update_icon()

/obj/item/gun/ballistic/revolver/shoot_live_shot(mob/living/user as mob|obj)
	..()
	advance_chamber()
	update_icon()

/obj/item/gun/ballistic/revolver/attack_self(mob/living/user)
	toggle_hammer(user)
	update_icon()

/obj/item/gun/ballistic/revolver/toggle_hammer(mob/living/user)
	var/

/obj/item/gun/ballistic/revolver/proc/eject_shells(mob/living/user, just_empties = TRUE)
	if(!magazine)
		return FALSE
	var/num_unloaded = 0
	var/list/ammo_mag = magazine.stored_ammo
	for(var/index in 1 to LAZYLEN(ammo_mag))
		if(!istype(ammo_mag[index], /obj/item/ammo_casing))
			continue
		var/obj/item/ammo_casing/bluuet = ammo_mag[index]
		if(just_empties && bluuet.BB)
			continue
		bluuet.forceMove(drop_location())
		bluuet.bounce_away(FALSE, NONE)
		if(chambered == bluuet)
			chambered = null
		ammo_mag[index] = null // eject a shell, it leaves a gap
		num_unloaded++
	update_icon()
	if (num_unloaded)
		if(just_empties)
			to_chat(user, span_notice("You unload [num_unloaded] empty shell\s from [src]."))
			return TRUE
		else
			to_chat(user, span_notice("You unload [num_unloaded] live round\s from [src]."))
			return TRUE
	else if(just_empties)
		return eject_shells(user, FALSE) // try again!

/obj/item/gun/ballistic/revolver/verb/spin()
	set name = "Spin Chamber"
	set category = "Object"
	set desc = "Click to spin your revolver's chamber."

	var/mob/M = usr

	if(M.stat || !in_range(M,src))
		return

	if(do_spin())
		usr.visible_message("[usr] spins [src]'s chamber.", span_notice("You spin [src]'s chamber."))
		playsound(src, 'sound/f13weapons/revolverspin.ogg', 30, 1)
	else
		verbs -= /obj/item/gun/ballistic/revolver/verb/spin

/obj/item/gun/ballistic/revolver/proc/do_spin()
	var/obj/item/ammo_box/magazine/internal/cylinder/C = magazine
	. = istype(C)
	if(.)
		C.spin()
		chamber_round(0)

/obj/item/gun/ballistic/revolver/can_shoot()
	return get_ammo(0,0)

/obj/item/gun/ballistic/revolver/get_ammo(countchambered = 0, countempties = 1)
	var/boolets = 0 //mature var names for mature people
	if (chambered && countchambered)
		boolets++
	if (magazine)
		boolets += magazine.ammo_count(countempties)
	return boolets

/obj/item/gun/ballistic/revolver/examine(mob/user)
	. = ..()
	. += "[get_ammo(0,0)] of those are live rounds."



//////////////////
// CODE ARCHIVE //
//////////////////

/*SLING CODE
/obj/item/gun/ballistic/revolver/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		if(A.use_tool(src, user, 0, 10, skill_gain_mult = EASY_USE_TOOL_MULT))
			slot_flags = INV_SLOTBIT_BACK
			to_chat(user, span_notice("You tie the lengths of cable to the shotgun, making a sling."))
			slung = TRUE
			update_icon()
		else
			to_chat(user, span_warning("You need at least ten lengths of cable if you want to make a sling!"))

/obj/item/gun/ballistic/revolver/doublebarrel/improvised/update_overlays()
	. = ..()
	if(slung)
		. += "[icon_state]sling"

/obj/item/gun/ballistic/revolver/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_icon()

//BREAK ACTION CODE
/obj/item/gun/ballistic/revolver/doublebarrel/attack_self(mob/living/user)
	var/num_unloaded = 0
	while (get_ammo() > 0)
		var/obj/item/ammo_casing/CB
		CB = magazine.get_round(0)
		chambered = null
		CB.forceMove(drop_location())
		CB.update_icon()
		num_unloaded++
	if (num_unloaded)
		to_chat(user, span_notice("You break open \the [src] and unload [num_unloaded] shell\s."))
	else
		to_chat(user, span_warning("[src] is empty!"))

//DODGE CODE
/obj/item/gun/ballistic/revolver/colt357/lucky/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		if(prob(block_chance))
			owner.visible_message(span_danger("[owner] seems to dodge [attack_text] entirely thanks to [src]!"))
			playsound(src, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, 1)
			return 1
	return 0


// -------------- HoS Modular Weapon System -------------
// ---------- Code originally from VoreStation ----------
/obj/item/gun/ballistic/revolver/mws
	name = "MWS-01 'Big Iron'"
	desc = "Modular Weapons System"

	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "mws"

	fire_sound = 'sound/weapons/Taser.ogg'

	mag_type = /obj/item/ammo_box/magazine/mws_mag
	spawnwithmagazine = FALSE

	recoil = 0

	var/charge_sections = 6

/obj/item/gun/ballistic/revolver/mws/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to remove the magazine.")

/obj/item/gun/ballistic/revolver/mws/shoot_with_empty_chamber(mob/living/user as mob|obj)
	process_chamber(user)
	if(!chambered || !chambered.BB)
		to_chat(user, span_danger("*click*"))
		playsound(src, "gun_dry_fire", 30, 1)


/obj/item/gun/ballistic/revolver/mws/process_chamber(mob/living/user)
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/mws_batt/shot = chambered
		if(shot.cell.charge >= shot.e_cost)
			shot.chargeshot()
		else
			for(var/B in magazine.stored_ammo)
				var/obj/item/ammo_casing/mws_batt/other_batt = B
				if(istype(other_batt,shot) && other_batt.cell.charge >= other_batt.e_cost)
					switch_to(other_batt, user)
					break
	update_icon()

/obj/item/gun/ballistic/revolver/mws/proc/switch_to(obj/item/ammo_casing/mws_batt/new_batt, mob/living/user)
	if(ishuman(user))
		if(chambered && new_batt.type == chambered.type)
			to_chat(user,span_warning("[src] is now using the next [new_batt.type_name] power cell."))
		else
			to_chat(user,span_warning("[src] is now firing [new_batt.type_name]."))

	chambered = new_batt
	update_icon()

/obj/item/gun/ballistic/revolver/mws/attack_self(mob/living/user)
	if(!chambered)
		return

	var/list/stored_ammo = magazine.stored_ammo

	if(stored_ammo.len == 1)
		return //silly you.

	//Find an ammotype that ISN'T the same, or exhaust the list and don't change.
	var/our_slot = stored_ammo.Find(chambered)

	for(var/index in 1 to stored_ammo.len)
		var/true_index = ((our_slot + index - 1) % stored_ammo.len) + 1 // Stupid ONE BASED lists!
		var/obj/item/ammo_casing/mws_batt/next_batt = stored_ammo[true_index]
		if(chambered != next_batt && !istype(next_batt, chambered.type) && next_batt.cell.charge >= next_batt.e_cost)
			switch_to(next_batt, user)
			break

/obj/item/gun/ballistic/revolver/mws/AltClick(mob/living/user)
	.=..()
	if(magazine)
		user.put_in_hands(magazine)
		magazine.update_icon()
		if(magazine.ammo_count())
			playsound(src, 'sound/weapons/gun_magazine_remove_full.ogg', 70, 1)
		else
			playsound(src, "gun_remove_empty_magazine", 70, 1)
		magazine = null
		to_chat(user, span_notice("You pull the magazine out of [src]."))
		if(chambered)
			chambered = null
		update_icon()

/obj/item/gun/ballistic/revolver/mws/update_overlays()
	.=..()
	if(!chambered)
		return

	var/obj/item/ammo_casing/mws_batt/batt = chambered
	var/batt_color = batt.type_color //Used many times

	//Mode bar
	var/image/mode_bar = image(icon, icon_state = "[initial(icon_state)]_type")
	mode_bar.color = batt_color
	. += mode_bar

	//Barrel color
	var/mutable_appearance/barrel_color = mutable_appearance(icon, "[initial(icon_state)]_barrel", color = batt_color)
	barrel_color.alpha = 150
	. += barrel_color

	//Charge bar
	var/ratio = can_shoot() ? CEILING(clamp(batt.cell.charge / batt.cell.maxcharge, 0, 1) * charge_sections, 1) : 0
	for(var/i = 0, i < ratio, i++)
		var/mutable_appearance/charge_bar = mutable_appearance(icon,  "[initial(icon_state)]_charge", color = batt_color)
		charge_bar.pixel_x = i
		. += charge_bar


//ACCIDENTALLY SHOOT YOURSELF IN THE FACE CODE
/obj/item/gun/ballistic/revolver/reverse/can_trigger_gun(mob/living/user)
	if((HAS_TRAIT(user, TRAIT_CLUMSY)) || (user.mind && HAS_TRAIT(user.mind, TRAIT_CLOWN_MENTALITY)))
		return ..()
	if(process_fire(user, user, FALSE, null, BODY_ZONE_HEAD))
		user.visible_message(span_warning("[user] somehow manages to shoot [user.p_them()]self in the face!"), span_userdanger("You somehow shoot yourself in the face! How the hell?!"))
		user.emote("scream")
		user.drop_all_held_items()
		user.DefaultCombatKnockdown(80)
*/
