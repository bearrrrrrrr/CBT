/* 
 * file: box_kinds.dm
 * author: spudnuts
 * date: 10/3/12
 * desc: Preset datums that define how long it takes for an ammoholder to
 * take an ammo from another ammoholder
 * Not stored on the ammoholder, theyre stored in a global list
 * and accessed by key (we're a 32 bit nightmare after all!)
 *
 * also defines what it accepts as a speedloader, in which case the delay is used
 * for transfering the whole thing into this thing
 */

// format: "string" = initted /datum/ammoholder_behavior,
GLOBAL_LIST_EMPTY(ammoholder_behaviors)

/datum/ammoholder_behavior
	var/key = AMMOB_DEFAULT
	var/kind = AH_BOX
	var/from_casing             = 1 SECONDS
	var/from_box                = 1 SECONDS
	var/from_clip               = 1 SECONDS
	var/from_crate              = 1 SECONDS
	var/from_magazine           = 1 SECONDS
	var/from_speedloader        = 1 SECONDS
	var/from_tube               = 1 SECONDS
	var/from_internal           = 1 SECONDS
	var/fallback                = 1 SECONDS
	var/list/speedloaders       = list()
	var/list/can_move_and_load  = list()

/datum/ammoholder_behavior/Destroy(force, ...)
	. = ..()
	GLOB.ammoholder_behaviors -= key

/datum/ammoholder_behavior/proc/get_delay(ammo)
	if(istype(ammo, /obj/item/ammo_casing))
		return from_casing
	else if (istype(ammo, /obj/item/ammo_box))
		var/obj/item/ammo_box/ab = ammo
		var/datum/ammoholder_behavior/theirs = ab.get_load_behavior()
		if(theirs)
			switch(theirs.kind)
				if(AH_BOX)
					return from_box
				if(AH_CLIP)
					return from_clip
				if(AH_CRATE)
					return from_crate
				if(AH_MAGAZINE)
					return from_magazine
				if(AH_SPEEDLOADER)
					return from_speedloader
				if(AH_SPEEDTUBE)
					return from_tube
				if(AH_INTERNAL)
					return from_internal
	return fallback

/datum/ammoholder_behavior/proc/is_speedloader(obj/item/ammo_box/ab)
	if(!istype(ab))
		return FALSE
	var/datum/ammoholder_behavior/theirs = ab.get_load_behavior()
	if(!istype(theirs))
		return FALSE
	return (theirs.kind in speedloaders)

/datum/ammoholder_behavior/proc/can_move_while_loading(ammo)
	if(istype(ammo, /obj/item/ammo_casing))
		return TRUE
	if(istype(ammo, /obj/item/ammo_box))
		var/obj/item/ammo_box/ab = ammo
		var/datum/ammoholder_behavior/theirs = ab.get_load_behavior()
		if(!istype(theirs))
			return FALSE
		return (theirs.kind in can_move_and_load)
	return FALSE

/// middle of the road, convenient to put into other containers / guns
/// but you gotta stand still for most of it
/datum/ammoholder_behavior/box
	key = AMMOB_BOX
	kind = AH_BOX
	from_casing             = 0.7 SECONDS
	from_box                = 0.5 SECONDS
	from_clip               = 1 SECONDS
	from_crate              = 0.2 SECONDS
	from_magazine           = 0.8 SECONDS
	from_speedloader        = 1 SECONDS
	from_tube               = 1 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_CLIP,
		AH_SPEEDTUBE,
		AH_SPEEDLOADER,
	)
	can_move_and_load       = list(
		AH_CLIP,
		AH_SPEEDTUBE,
		AH_SPEEDLOADER,
	)

/// easy to dump ammo into it, hard to transfer ammo out of it
/datum/ammoholder_behavior/crate
	key = AMMOB_CRATE
	kind = AH_CRATE
	from_casing             = 0.3 SECONDS
	from_box                = 2 SECONDS
	from_clip               = 1 SECONDS
	from_crate              = 3 SECONDS
	from_magazine           = 1 SECONDS
	from_speedloader        = 1 SECONDS
	from_tube               = 1 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_CLIP,
		AH_SPEEDLOADER,
		AH_SPEEDTUBE,
		AH_BOX,
		AH_CRATE,
		AH_MAGAZINE,
	)
	can_move_and_load       = list()

/// External magazines, slow to be loaded
/// but they swap easily
/datum/ammoholder_behavior/magazine
	key = AMMOB_MAGAZINE
	kind = AH_MAGAZINE
	from_casing             = 0.8 SECONDS
	from_box                = 0.8 SECONDS
	from_clip               = 1 SECONDS
	from_crate              = 1 SECONDS
	from_magazine           = 1 SECONDS
	from_speedloader        = 2 SECONDS
	from_tube               = 2 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_CLIP,
	)
	can_move_and_load       = list(
		AH_CLIP,
	)

/// Internal mag like a hunting rifle
/// Slow to load from anything but loosies and clips (use a clip!!)
/datum/ammoholder_behavior/internal_cliploader
	key = AMMOB_INTERNAL_CLIPLOADER
	kind = AH_INTERNAL
	from_casing             = 0.8 SECONDS
	from_box                = 1 SECONDS
	from_clip               = 2 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 1.3 SECONDS
	from_speedloader        = 2 SECONDS
	from_tube               = 2 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_CLIP,
	)
	can_move_and_load       = list(
		AH_CLIP,
	)

/// Internal mag like a revolver
/// Slow to load from anything but loosies and speedloaders (use a speedloader!!)
/datum/ammoholder_behavior/internal_revolver
	key = AMMOB_INTERNAL_REVOLVER_CYLINDER
	kind = AH_INTERNAL
	from_casing             = 0.8 SECONDS
	from_box                = 1.3 SECONDS
	from_clip               = 1.3 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 1.3 SECONDS
	from_speedloader        = 1.2 SECONDS
	from_tube               = 2 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_SPEEDLOADER,
	)
	can_move_and_load       = list(
		AH_SPEEDLOADER,
	)

/// Internal mag like a repeater
/// Slow to load from anything but loosies and tubes (use a tubes!!)
/datum/ammoholder_behavior/internal_tube
	key = AMMOB_INTERNAL_REPEATER_TUBE
	kind = AH_INTERNAL
	from_casing             = 0.8 SECONDS
	from_box                = 1 SECONDS
	from_clip               = 2 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 2 SECONDS
	from_speedloader        = 2 SECONDS
	from_tube               = 2 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_SPEEDTUBE,
	)
	can_move_and_load       = list(
		AH_SPEEDTUBE,
		AH_BOX,
	)

/// Stripper clip
/// Quick to load from most sources
/datum/ammoholder_behavior/stripper_clip
	key = AMMOB_STRIPPER_CLIP
	kind = AH_CLIP
	from_casing             = 0.8 SECONDS
	from_box                = 1 SECONDS
	from_clip               = 0.5 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 1 SECONDS
	from_speedloader        = 2 SECONDS
	from_tube               = 2 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_CLIP,
	)
	can_move_and_load       = list()

/// Revolver speedloader
/// Quick to load from most sources, cant be speedloaded tho
/datum/ammoholder_behavior/revolver_speedloader
	key = AMMOB_REVOLVER_SPEEDLOADER
	kind = AH_SPEEDLOADER
	from_casing             = 0.8 SECONDS
	from_box                = 1 SECONDS
	from_clip               = 1.5 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 1.5 SECONDS
	from_speedloader        = 1.5 SECONDS
	from_tube               = 1.5 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list()
	can_move_and_load       = list()

/// Repeater speed tube
/// Quick to load from most sources
/datum/ammoholder_behavior/repeater_speedtube
	key = AMMOB_REPEATER_SPEEDTUBE
	kind = AH_SPEEDTUBE
	from_casing             = 0.8 SECONDS
	from_box                = 1 SECONDS
	from_clip               = 2 SECONDS
	from_crate              = 2 SECONDS
	from_magazine           = 1 SECONDS
	from_speedloader        = 0.5 SECONDS
	from_tube               = 1 SECONDS
	fallback                = 1 SECONDS
	speedloaders            = list(
		AH_SPEEDTUBE
	)
	can_move_and_load       = list()











