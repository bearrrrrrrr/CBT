/* * * * * * * * * *
 * LIGHT REVOLVERS *
 * * * * * * * * * */

/* * * * * * * * * * *
 * .22 detective
 * Extra light revolver
 * .22 Special
 * Tiny
 * Fits in a boot
 * Renamable?
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/detective
	name = ".22LR revolver"
	desc = "A small revolver thats easily concealable."
	icon_state = "detective"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev22
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T5
	init_recoil = HANDGUN_RECOIL(1, 1)
	init_firemodes = list(
		/datum/firemode/semi_auto/faster
	)

/obj/item/gun/ballistic/revolver/detective/derringer
	name = ".22LR derringer"
	desc = "A small four barrel derringer, designed to fire two barrels at a time."
	icon = 'modular_coyote/icons/objects/pistols.dmi'
	icon_state = "derringer"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev22/four
	init_firemodes = list(
		/datum/firemode/burst/two/faster
	)

/obj/item/gun/ballistic/revolver/detective/derringer/update_icon_state()
	if(!magazine || !get_ammo(TRUE, FALSE) || !chambered?.BB)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"

/*	obj_flags = UNIQUE_RENAME
	prefered_power = CASING_POWER_LIGHT_PISTOL * CASING_POWER_MOD_SURPLUS
	misfire_possibilities = list(
		GUN_MISFIRE_HURTS_USER(5, 5, 15, BRUTELOSS | FIRELOSS),
		GUN_MISFIRE_THROWS_GUN(2)
	)

	/obj/item/gun/ballistic/revolver/detective/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!(CALIBER_357 in magazine.caliber))
		to_chat(user, span_notice("You begin to reinforce the barrel of [src]..."))
		if(magazine.ammo_count())
			afterattack(user, user)	//you know the drill
			user.visible_message(span_danger("[src] goes off!"), span_userdanger("[src] goes off in your face!"))
			return TRUE
		if(I.use_tool(src, user, 30))
			magazine.caliber |= CALIBER_357
			desc = "The barrel and chamber assembly seems to have been modified."
			to_chat(user, span_notice("You reinforce the barrel of [src]. Now it will fire .357 rounds."))
	return TRUE */

/* * * * * * * * * * *
 * .45 ACP Revolver
 * Light revolver
 * .45 ACP
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/revolver45
	name = "S&W .45 ACP revolver"
	desc = "Smith and Wesson revolver firing .45 ACP from a seven round cylinder."
	inhand_icon_state = "45revolver"
	icon_state = "45revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto
	)
	fire_sound = 'sound/f13weapons/45revolver.ogg'


/* * * * * * * * * * *
 * Hermes revolver
 * Light, Fast and hyper accurate
 * 9mm
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/hermes
	name = "Hermes Sporting Revolver"
	desc = "A slick, well machined 9mm revolver made for olympic target shooting, extremely accurate and fast firing, though lacking in stopping power"
	icon_state = "hermes"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/hermes
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	init_recoil = HANDGUN_RECOIL(1, 1)
	init_firemodes = list(
		/datum/firemode/semi_auto/faster,
		/datum/firemode/automatic/rpm300,
	)
	use_casing_sounds = TRUE

/* * * * * * * * * *
 * HEAVY REVOLVERS *
 * * * * * * * * * */

/* * * * * * * * * * *
 * .357 revolver
 * Baseline heavy revolver
 * .357 magnum
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/colt357
	name = "\improper .357 magnum revolver"
	desc = "A no-nonsense revolver, more than likely made in some crude workshop in one of the more prosperous frontier towns."
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

//full auto .357 revolver. shoots wayfast
/obj/item/gun/ballistic/revolver/colt357/auto
	name = "auto-revolver"
	desc = "A heavy .357 revolver with a custom recoil system."
	icon_state = "colt6520"
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_firemodes = list(
		/datum/firemode/automatic/rpm150,
		/datum/firemode/semi_auto/faster
	)

/* * * * * * * * * * *
 * Medusa Revolver
 * Slow, innacurate but convenient
 * From .22 up to .44
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/medusa
	name = "Medusa Multi-Caliber Revolver"
	desc = "A hefty Pre-Fall revolver with an unusual multi-caliber cylinder that's able to fit .22 up to .44, though the loose chambering makes it rather innacurate."
	icon_state = "medusa"
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/medusa
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	added_spread = GUN_SPREAD_POOR
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)

	can_flashlight = TRUE
	scope_state = "flight"
	flight_x_offset = 22
	flight_y_offset = 15

	use_casing_sounds = TRUE

/* * * * * * * * * * *
 * Mateba revolver
 * Cool? heavy revolver
 * .357 magnum
 * Unique
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/colt357/mateba //this is a skin that rigbe wanted
	name = "\improper Unica 6 auto-revolver"
	desc = "A Pre-Fall high-power autorevolver commonly used by people who think they look cool."
	icon_state = "mateba"
	inhand_icon_state = "mateba"
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	fire_sound = 'sound/f13weapons/magnum_fire.ogg'

/* * * * * * * * * * *
 * Lucky revolver
 * Blocking heavy revolver
 * .357 magnum
 * Unique
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/colt357/lucky
	name = "Lucky"
	desc = "Just holding this gun makes you feel like an ace. This revolver was handmade from pieces of other guns in some workshop after the war. A one-of-a-kind gun, it was someone's lucky gun for many a year, it's in good condition and hasn't changed hands often."
	icon_state = "lucky37"
	inhand_icon_state = "lucky"
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	block_chance = 20

/* * * * * * * * * * *
 * Police revolver
 * Smol heavy revolver
 * .357 magnum
 * Less accurate
 * Lighter
 * Less Melee
 * More recoil
 * Less damage
 * Faster shot
 * Small
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/police
	name = "police revolver"
	desc = "Pre-Fall double action police revolver chambered in .357 magnum."
	icon_state = "police"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev357
	weapon_class = WEAPON_CLASS_TINY
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1, 1)
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	fire_sound = 'sound/f13weapons/policepistol.ogg'
	gun_accuracy_zone_type = ZONE_WEIGHT_AUTOMATIC // limbfucker2000

/obj/item/gun/ballistic/revolver/police/webley
	name = "Webley Revolver"
	desc = "The Webley Revolver was the Pre-Fall standard issue service pistol for the armed forces of the United Kingdom, and countries of the British Empire."
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	icon_state = "webley"
	inhand_icon_state = "police"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev357
	weapon_class = WEAPON_CLASS_TINY
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1, 1)
	init_firemodes = list(
		/datum/firemode/semi_auto/faster
	)
	fire_sound = 'sound/f13weapons/policepistol.ogg'
	gun_accuracy_zone_type = ZONE_WEIGHT_AUTOMATIC // limbfucker2000


/* * * * * * * * * * *
 * .44 magnum revolver
 * Heavier revolver
 * .44 magnum
 * Scope!
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/m29
	name = ".44 magnum revolver"
	desc = "Powerful handgun for those who want to travel the wasteland safely in style. Has a bit of a kick."
	inhand_icon_state = "model29"
	icon_state = "m29"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev44
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	can_scope = TRUE
	scope_state = "revolver_scope"
	scope_x_offset = 6
	scope_y_offset = 24
	fire_sound = 'sound/f13weapons/44mag.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
/* * * * * * * * * * *
 * Pearly .44 magnum revolver
 * Cute heavier revolver
 * .44 magnum
 * Scope!
 * Unique
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/m29/alt
	desc = "Powerful handgun with a bit of a kick. This one has nickled finish and pearly grip, and has been kept in good condition by its owner."
	inhand_icon_state = "44magnum"
	icon_state = "mysterious_m29"
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	can_scope = TRUE
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)

/* * * * * * * * * * *
 * Peacekeeper revolver
 * Quickfire heavier revolver
 * .44 magnum
 * Scope!
 * Quick fire
 * Heavy recoil
 * Unique
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/m29/peacekeeper
	name = "Peacekeeper"
	desc = "When you don't just need excessive force, but crave it. This .44 has a special hammer mechanism, allowing for measured powerful shots, or fanning for a flurry of inaccurate shots."
	inhand_icon_state = "m29peace"
	icon_state = "m29peace"
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	can_scope = FALSE

/* * * * * * * * * * *
 * Snubnose .44 revolver
 * Smol heavier revolver
 * .44 magnum
 * Less accurate
 * Lighter
 * Less Melee
 * More recoil
 * Less damage
 * Faster shot
 * TINY
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/m29/snub
	name = "snubnose .44 magnum revolver"
	desc = "A snubnose variant of the commonplace .44 magnum. An excellent holdout weapon for self defense."
	icon_state = "m29_snub"
	weapon_class = WEAPON_CLASS_TINY
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	gun_accuracy_zone_type = ZONE_WEIGHT_AUTOMATIC
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
/* * * * * * * * * * *
 * .44 single-action revolver
 * Slow heavier revolver
 * .44 magnum
 * Scope!
 * Accurate
 * Slow to fire
 * More damage
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/revolver44
	name = "\improper .44 magnum single-action revolver"
	desc = "I hadn't noticed, but there on his hip, was a moderately sized iron..."
	inhand_icon_state = "44colt"
	icon_state = "44colt"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev44
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1, 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = TRUE
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)
	fire_sound = 'sound/f13weapons/44revolver.ogg'

/* * * * * * * * * * * * * *
* Lemat Revolver
* -9mm chambering
* + 9 shot cylinder
* + Common revolver
* + 9mm but is on par with most revolvers. Hopefully
* * * * * * * * * * * * * * */
/obj/item/gun/ballistic/revolver/Lemat
	name = "Grapeshot Revolver"
	desc = "A 9 shot revolver from a time long forgotten. The revolver itself has been refitted to be 9mm. Unlike the original version, this one needs no wax caps or .36cal balls to be fitted into the cylinder. It also does not take a shotgun shell. But at least you have 9 shots to put your target down."
	inhand_icon_state = "lemat"
	icon_state = "lemat"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/lemat
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T2
	init_recoil = HANDGUN_RECOIL (1 , 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = FALSE
	can_suppress = FALSE
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	fire_sound = 'sound/f13weapons/44revolver.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto
	)

/obj/item/gun/ballistic/revolver/Lemat/customrevolvers //custom revolver
	name = "'Cain' 9mm revolver"
	desc = "A custom 9 shot revolver!"
	inhand_icon_state = "crevolver"
	icon_state = "lucky"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/lemat
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T2
	init_recoil = HANDGUN_RECOIL (1 , 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = FALSE
	can_suppress = FALSE
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	fire_sound = 'sound/f13weapons/44revolver.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto
	)

/obj/item/gun/ballistic/revolver/Lemat/customrevolvers/second //custom revolver, comes with a revolver called cain
	name = "'Abel' 9mm revolver"
	desc = "A custom 9 shot revolver!"
	inhand_icon_state = "crevolver"
	icon_state = "lucky"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/lemat
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T2
	init_recoil = HANDGUN_RECOIL (1 , 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = FALSE
	can_suppress = FALSE
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	fire_sound = 'sound/f13weapons/44revolver.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto
	)

/obj/item/gun/ballistic/revolver/Lemat/custom
	name = "Engraved LeMat Revolver"
	desc = "An engraved golden LeMat revolver with an ivory grip handle. Engraved onto the barrel of the gun is the phrase 'Bound by love' in Icelandic. The ivory grip has the face of a moth on both sides."
	inhand_icon_state = "goldengun"
	icon_state = "toxlemat"

/* * * * * * * * * * *
 * Desert ranger revolver
 * Cool heavier revolver
 * .44 magnum
 * Scope!
 * Accurate
 * Slow to fire
 * More damage
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/revolver44/desert_ranger
	name = "desert ranger revolver"
	desc = "I hadn't noticed, but there on his hip, was a really spiffy looking iron..."
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1, 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = TRUE
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)
/* * * * * * * * * * *
 * M2045 Magnum Revolver Rifle
 * Heavy revolver rifle
 * Scoped
 * .308
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/m2405
	name = "M2045 Magnum Revolver Rifle"
	desc = "A relic from before the Great War returns to the wasteland. This rifle uses .308 ammunition and has considerable recoil."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev308
	icon = 'icons/fallout/objects/guns/longguns.dmi'
	inhand_icon_state = "m2405"
	icon_state = "m2405"
	weapon_class = WEAPON_CLASS_CARBINE
	weapon_weight = GUN_ONE_HAND_ONLY
	damage_multiplier = GUN_EXTRA_DAMAGE_T1
	init_recoil = RIFLE_RECOIL(2.2, 2.2)
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	zoomable = TRUE
	zoom_amt = 10
	zoom_out_amt = 13



/* * * * * * * * * * * *
* Colt Buntline revolver
* - 6 shots only like any else revolver
* + Revolver rifle configuration, allows use of scopes
* + Carbine class
* + .357 ammo
* + Uncommon
* * * * * * * * * * * * */
/obj/item/gun/ballistic/revolver/buntline
	name = "Colt Buntline"
	desc = "A Colt Buntline revolver. The revolver itself is the same as any else single action army albeit it's been rechambered to fit .45 LC. It also comes with an elongated barrel and attachable stock. For when you wanna hit the cowpokes from afar."
	icon_state = "coltcarbine"
	inhand_icon_state = "coltcarbine"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45/gunslinger
	weapon_class = WEAPON_CLASS_CARBINE
	weapon_weight = GUN_TWO_HAND_ONLY
	damage_multiplier = GUN_EXTRA_DAMAGE_T1
	init_recoil = SMG_RECOIL(2, 2)
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	can_scope = TRUE
	can_suppress = FALSE
	can_bayonet = FALSE

/* * * * * * * * * * *
* Judge revolver
* + 3 shot shotgun revolver
* * * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/taurjudge
	name = "Taurus Judge"
	desc = "A Taurus manfactured Judge. This model specifically takes 3 shotgun shells, useful for unloading hell upon the enemy. Do they feel lucky?"
	icon_state = "judge"
	inhand_icon_state = "judge"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/judge
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T1 // to keep this loot revolver competitive
	init_recoil = HMG_RECOIL(2, 2)
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)
	can_scope = FALSE
	can_suppress = FALSE
	can_bayonet = FALSE

//4.7mm revolver. 6 shots, caseless ammo and shy extra damage. Spawn gun, fires faster
/obj/item/gun/ballistic/revolver/revolver47mm
	name = "4.7mm revolver 2190 edition."
	desc = "A odd 6-cylinder 4.7mm caseless revolver. The cylinder is square-ish in nature while the revolver is a shy bit more heavy. Seems to hit about average, but fires slowly due to a heavy trigger and hammer."
	icon_state = "47rev"
	inhand_icon_state = "lucky"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev47mm
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T2
	init_recoil = HANDGUN_RECOIL(1.4, 1.6)
	init_firemodes = list(
		/datum/firemode/semi_auto
	)
	can_scope = FALSE
	can_suppress = FALSE
	can_bayonet = FALSE

//5mm revolver. More ammo than 4.7mm at 7 shots a cylinder, hits harder but fires slower. spawn gun
/obj/item/gun/ballistic/revolver/revolver5mm
	name = "5mm break-action revolver"
	desc = "A 7-cylinder 5mm break action revolver. The revolver seems to be average in appearance. It also has a bit of a heavy trigger, affecting firerate!"
	icon_state = "5rev"
	inhand_icon_state = "model29"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev5mm
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T3
	init_recoil = HANDGUN_RECOIL(1.2, 1.4)
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	can_scope = FALSE
	can_suppress = FALSE
	can_bayonet = FALSE

// heavy duty needler revolving rifle
/obj/item/gun/ballistic/revolver/needlerrifle
	name = "OT-64 Heavy Needler rifle"
	desc = "A shoulder mounted OT-64 rifle. It was manufactured in Nepal by Latos Systems in collaboration with Nepal anti-armor divisions. It uses a heavy duty red needler round that's on par with the size and length of a 20mm shell. Albeit it doesn't hit hard, interestingly."
	icon_state = "heavyneedle"
	inhand_icon_state = "heavyneedle"
	icon = 'icons/fallout/objects/guns/ballistic.dmi'
	lefthand_file = 'icons/fallout/onmob/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/fallout/onmob/weapons/guns_righthand.dmi'
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/heavyneedler
	weapon_class = WEAPON_CLASS_RIFLE
	weapon_weight = GUN_TWO_HAND_ONLY
	init_recoil = HMG_RECOIL(2, 1.3)
	slowdown = GUN_SLOWDOWN_RIFLE_BOLT
	init_firemodes = list(
		/datum/firemode/semi_auto
	)
	can_scope = TRUE
	can_suppress = FALSE
	can_bayonet = FALSE

	fire_sound = 'sound/f13weapons/needler.ogg'

/* * * * * * * * * * *
 * Hunting revolver
 * Super heavy revolver
 * .45-70
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/hunting
	name = "hunting revolver"
	desc = "A scoped double action revolver chambered in 45-70."
	icon_state = "hunting_revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = TRUE
	scope_state = "revolver_scope"
	scope_x_offset = 9
	scope_y_offset = 20
	fire_sound = 'sound/f13weapons/sequoia.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)

/obj/item/gun/ballistic/revolver/hunting/custom
	name = "Deireadh le ceantar revolver"
	desc = "A scopable double action revolver chambered in 45-70. It seems custom made and fairly weaker than its original counterpart."
	icon_state = "hunting_revolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T3
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	can_scope = TRUE
	scope_state = "revolver_scope"
	scope_x_offset = 9
	scope_y_offset = 20
	fire_sound = 'sound/f13weapons/sequoia.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)

/obj/item/gun/ballistic/revolver/derringer4570
	name = ".45-70 derringer"
	desc = "An overcompensating little gun that offers a high degree of precision firepower in a tiny package, if you can handle the recoil"
	icon = 'modular_coyote/icons/objects/pistols.dmi'
	icon_state = "derringerX"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570/two
	weapon_class = WEAPON_CLASS_TINY
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_LESS_DAMAGE_T1
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	fire_sound = 'sound/f13weapons/sequoia.ogg'
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)

/obj/item/gun/ballistic/revolver/derringer4570/update_icon_state()
	if(!magazine || !get_ammo(TRUE, FALSE) || !chambered?.BB)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"

/* * * * * * * * * * *
 * Degraded hunting revolver
 * Really heavy revolver
 * .45-70
 * Even less damage
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/hunting/klatue
	name = "degraded hunting revolver"
	desc = "A scoped double action revolver chambered in 45-70. This one is very worn."
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_T2
	init_firemodes = list(
		/datum/firemode/semi_auto/slower
	)
/* * * * * * * * * * *
 * Sequoia revolvers
 * Super heavy revolver
 * .45-70
 * Accurate
 * Slow to fire
 * More damage
 * They're all the same gun really
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/sequoia
	name = "desert sequoia"
	desc = "This large, double-action revolver is a trademark weapon of the Desert Rangers. It features a dark finish with intricate engravings etched all around the weapon. Engraved along the barrel are the words 'For Honorable Service,' and 'Against All Tyrants.' The hand grip is oddly comfortable in your hand  The entire weapon is suited for quick-drawing."
	icon_state = "sequoia"
	inhand_icon_state = "sequoia"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0 //it does plenty of damage without a boost >.>
	init_recoil = HANDGUN_RECOIL(1.2, 1.2)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	fire_sound = 'sound/f13weapons/sequoia.ogg'

/obj/item/gun/ballistic/revolver/sequoia/bayonet
	name = "bladed ranger sequoia"
	desc = "This large, double-action revolver is a trademark weapon of the Desert Rangers. It features a dark finish with intricate engravings etched all around the weapon. Engraved along the barrel are the words 'For Honorable Service,' and 'Against All Tyrants.' The hand grip has a blade attached to the bottom. You know, for stabbin'."
	icon_state = "sequoia_b"
	inhand_icon_state = "sequoia"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570
	force = GUN_MELEE_FORCE_PISTOL_HEAVY * 1.5
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	fire_sound = 'sound/f13weapons/sequoia.ogg'

/obj/item/gun/ballistic/revolver/sequoia/death
	name = "Desert Hemlock"
	desc = "This large, double-action revolver is a trademark weapon of the Desert Rangers. It features a dark finish with intricate engravings etched all around the weapon. Engraved along the barrel are the words 'For Honorable Service,' and 'Against All Tyrants.' The hand grip bears slight singe-marks..."
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev4570
	fire_sound = 'sound/f13weapons/sequoia.ogg'
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
/* * * * * * * * * * *
 * Single Action Army revolvers
 * Bouncy revolver
 * .45LC
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/revolver45/gunslinger
	name = "\improper Colt Single Action Army"
	desc = "A Colt Single Action Army, chambered in the archaic .45 long colt cartridge."
	inhand_icon_state = "coltwalker"
	icon_state = "peacemaker"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45/gunslinger
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_recoil = HANDGUN_RECOIL(1, 1)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	init_firemodes = list(
		/datum/firemode/semi_auto/slow
	)
	fire_sound = 'sound/f13weapons/45revolver.ogg'

/obj/item/gun/ballistic/revolver/derringerLC
	name = ".45 LC derringer"
	desc = "A classy, pearl handled derringer firing .45LC in a compact package."
	icon = 'modular_coyote/icons/objects/pistols.dmi'
	icon_state = "remington_95_ivory"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rev45/two
	weapon_class = WEAPON_CLASS_TINY
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_recoil = HANDGUN_RECOIL(1, 1)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	fire_sound = 'sound/f13weapons/45revolver.ogg'

/obj/item/gun/ballistic/revolver/derringerLC/update_icon_state()
	if(!magazine || !get_ammo(TRUE, FALSE) || !chambered?.BB)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)]"

/* * * * * * * * * * *
 * .223 revolver
 * Quirky revolver
 * .223 / 5.56mm
 * Light
 * Two-Gun
 * Awful accuracy
 * Longer recoil recovery
 * Slower draw
 * Common
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/thatgun
	name = ".308 Pistol"
	desc = "A strange pistol firing rifle ammunition, possibly damaging the users wrist and with poor accuracy."
	icon_state = "thatgun"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/thatgun
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	gun_accuracy_zone_type = ZONE_WEIGHT_AUTOMATIC
	init_firemodes = list(
		/datum/firemode/semi_auto/fast
	)
	fire_sound = 'sound/f13weapons/magnum_fire.ogg'

/* * * * * * * * * * *
 * Needler 'revolver'
 * Wounding revolver
 * Needles
 * Uncommon
 * * * * * * * * * * */

/obj/item/gun/ballistic/revolver/needler
	name = "Needler pistol"
	desc = "You suspect this Bringham needler pistol was once used in scientific field studies. It uses small hard-plastic hypodermic darts as ammo. "
	icon_state = "needler"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/revneedler
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_recoil = HANDGUN_RECOIL(0.8, 0.8)
	gun_accuracy_zone_type = ZONE_WEIGHT_PRECISION
	init_firemodes = list(
		/datum/firemode/semi_auto/faster
	)
	silenced = TRUE
	fire_sound = 'sound/weapons/gunshot_silenced.ogg'
	fire_sound_silenced = 'sound/weapons/gunshot_silenced.ogg'

/obj/item/gun/ballistic/revolver/needler/ultra
	name = "Ultracite needler"
	desc = "An ultracite enhanced needler pistol." //Sounds like lame bethesda stuff to me
	icon_state = "ultraneedler"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/revneedler
	weapon_class = WEAPON_CLASS_SMALL
	weapon_weight = GUN_ONE_HAND_AKIMBO
	damage_multiplier = GUN_EXTRA_DAMAGE_0
	init_firemodes = list(
		/datum/firemode/semi_auto/faster
	)
	fire_sound = 'sound/weapons/gunshot_silenced.ogg'

// LEGACY STUFF

// A gun to play Russian Roulette!
// You can spin the chamber to randomize the position of the bullet.

/obj/item/gun/ballistic/revolver/russian
	name = "deer hunting revolver"
	desc = "A revolver for drinking games. Uses .357 ammo, and has a mechanism requiring you to spin the chamber before each trigger pull."
	icon_state = "russianrevolver"
	mag_type = /obj/item/ammo_box/magazine/internal/cylinder/rus357
	var/spun = FALSE

/obj/item/gun/ballistic/revolver/russian/do_spin()
	. = ..()
	spun = TRUE

/obj/item/gun/ballistic/revolver/russian/Initialize()
	. = ..()
	do_spin()
	spun = TRUE
	update_icon()

/obj/item/gun/ballistic/revolver/russian/attackby(obj/item/A, mob/user, params)
	..()
	if(get_ammo() > 0)
		spin()
		spun = TRUE
	update_icon()
	A.update_icon()
	return

/obj/item/gun/ballistic/revolver/russian/attack_self(mob/user)
	if(!spun)
		spin()
		spun = TRUE
		return
	..()

/obj/item/gun/ballistic/revolver/russian/afterattack(atom/target, mob/living/user, flag, params)
	. = ..(null, user, flag, params)

	if(flag)
		if(!(target in user.contents) && ismob(target))
			if(user.a_intent == INTENT_HARM) // Flogging action
				return

	if(isliving(user))
		if(!can_trigger_gun(user))
			return
	if(target != user)
		if(ismob(target))
			to_chat(user, span_warning("A mechanism prevents you from shooting anyone but yourself!"))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!spun)
			to_chat(user, span_warning("You need to spin \the [src]'s chamber first!"))
			return

		spun = FALSE

		if(chambered)
			var/obj/item/ammo_casing/AC = chambered
			if(AC.fire_casing(user, user))
				playsound(user, fire_sound, 50, 1)
				var/zone = check_zone(user.zone_selected)
				var/obj/item/bodypart/affecting = H.get_bodypart(zone)
				if(zone == BODY_ZONE_HEAD || zone == BODY_ZONE_PRECISE_EYES || zone == BODY_ZONE_PRECISE_MOUTH)
					shoot_self(user, affecting)
				else
					user.visible_message(span_danger("[user.name] cowardly fires [src] at [user.p_their()] [affecting.name]!"), span_userdanger("You cowardly fire [src] at your [affecting.name]!"), span_italic("You hear a gunshot!"))
				chambered = null
				return

		user.visible_message(span_danger("*click*"))
		playsound(src, "gun_dry_fire", 30, 1)

/obj/item/gun/ballistic/revolver/russian/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, stam_cost = 0)
	add_fingerprint(user)
	playsound(src, "gun_dry_fire", 30, TRUE)
	user.visible_message(span_danger("[user.name] tries to fire \the [src] at the same time, but only succeeds at looking like an idiot."), span_danger("\The [src]'s anti-combat mechanism prevents you from firing it at the same time!"))

/obj/item/gun/ballistic/revolver/russian/proc/shoot_self(mob/living/carbon/human/user, affecting = BODY_ZONE_HEAD)
	user.apply_damage(300, BRUTE, affecting)
	user.visible_message(span_danger("[user.name] fires [src] at [user.p_their()] head!"), span_userdanger("You fire [src] at your head!"), span_italic("You hear a gunshot!"))

/obj/item/gun/ballistic/revolver/russian/soul
	name = "cursed Russian revolver"
	desc = "To play with this revolver requires wagering your very soul."

/obj/item/gun/ballistic/revolver/russian/soul/shoot_self(mob/living/user)
	..()
	var/obj/item/soulstone/anybody/SS = new /obj/item/soulstone/anybody(get_turf(src))
	if(!SS.transfer_soul("FORCE", user)) //Something went wrong
		qdel(SS)
		return
	user.visible_message(span_danger("[user.name]'s soul is captured by \the [src]!"), span_userdanger("You've lost the gamble! Your soul is forfeit!"))
