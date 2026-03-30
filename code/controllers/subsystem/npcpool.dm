/* 
 * NPC POOL SUBSYSTEM
 * Handles NPC mob AI heartbeats
 * Want to make mobs tick more often? adjust the wait time!
 * Does NOT handle stuff like Life or anything other than AI movement, speech, and actions
 * That stuff is handled by SSmobs!
 * Also handles the wander attractor system
 * */
SUBSYSTEM_DEF(npcpool)
	name = "NPC Pool"
	flags = SS_POST_FIRE_TIMING|SS_NO_INIT|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = (0.5 SECONDS)

	var/list/currentrun = list()

	/// List of attractors that cause mobs to wander towards them
	/// See more in /datum/wander_attractor
	/// format: list("some_kind_of_ID" = initted/datum/wander_attractor)
	var/list/wander_attractors = list()
	var/debug_attraction = TRUE

/datum/controller/subsystem/npcpool/stat_entry(msg)
	var/list/activelist = GLOB.simple_animals[AI_ON]
	msg = "NPCS:[length(activelist)]"
	return ..()

/datum/controller/subsystem/npcpool/fire(resumed = FALSE)

	if (!resumed)
		var/list/activelist = GLOB.simple_animals[AI_ON]
		src.currentrun = activelist.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/mob/living/simple_animal/SA = currentrun[currentrun.len]
		--currentrun.len

		if (QDELETED(SA)) // Some issue causes nulls to get into this list some times. This keeps it running, but the bug is still there.
			GLOB.simple_animals[AI_ON] -= SA
			stack_trace("Found a null in simple_animals active list [SA.type]!")
			continue

		if(!SA.ckey && !SA.mob_transforming)
			if(SA.stat != DEAD)
				SA.handle_automated_movement()
			if(SA.stat != DEAD)
				SA.handle_automated_action()
			if(SA.stat != DEAD)
				SA.handle_automated_speech()
		if (MC_TICK_CHECK)
			return




/* WANDER ATTRACTOR!! */
/* 
 * When something in the game world makes a sound or some sort of allurance to mobs,
 * it does a ranged check for mobs in the area! It then compares the allurance to the
 * intensity of the attractor they subscribe to (if any), and if the allurance is higher,
 * they will wander towards the attractor for a bit! This is used for things like ferals
 * hearing a gunshot, or grenade, or something. maybe even some gecko musk to get them to
 * be all horny for you! =^w^=
 */
/datum/controller/subsystem/npcpool/proc/make_attraction(atom/doer, intensity, max_range, duration = (30 SECONDS))
	if(!doer)
		return
	if(intensity <= 0)
		return
	if(max_range <= 0)
		return
	for(var/mob/living/simple_animal/M in GLOB.simple_animals[AI_ON])
		if(!M.attractable)
			continue
		if(GET_DIST_EUCLIDEAN(M, doer)) > max_range
			continue
		var/datum/wander_attractor/attractor = SSmobs.wander_attractors[M.wander_attractor_ID]
		if(!istype(attractor, /datum/wander_attractor))
			give_attractor(M, intensity, max_range, duration)
		else if(attractor.IsThatMoreIntense(doer, intensity))
			give_attractor(M, intensity, max_range, duration)

/datum/controller/subsystem/npcpool/proc/give_attractor(mob/living/simple_animal/M, intensity, max_range)
	//first, modulate the intensity by distance, so that the farther away you are, the less effective the attractor is!
	intensity = modulate_intensity_by_distance(M, intensity, max_range)
	var/datum/wander_attractor/attractor = new (intensity, max_range, duration) // 30 seconds duration for now, maybe make this variable later?
	M.wander_attractor_ID = attractor.ID
	attractor.Subscribe()
	return attractor

/datum/controller/subsystem/npcpool/proc/modulate_intensity_by_distance(mob/living/simple_animal/M, intensity, max_range)
	var/distance = GET_DIST_EUCLIDEAN(M, doer)
	if(distance > max_range)
		return 0
	if(area_of_effect == 0) // avoid divide by zero
		return intensity
	var/modulated_intensity = intensity * (1 - (distance / max_range))
	return modulated_intensity

/datum/wander_attractor
	var/ID
	var/die_time
	var/intensity
	var/area_of_effect
	var/my_x = 0
	var/my_y = 0
	var/my_z = 0
	var/subs = 0

/datum/wander_attractor/New(intensity, area_of_effect, duration = (30 SECONDS))
	var/attractor = new()
	attractor.intensity = intensity
	attractor.area_of_effect = area_of_effect
	attractor.die_time = world.time + duration
	ID = generate_random_id()
	. = ..()
	SSmobs.wander_attractors[ID] = attractor

/datum/wander_attractor/Destroy()
	SSmobs.wander_attractors.Remove(ID)
	. = ..()

/datum/wander_attractor/proc/Subscribe()
	subs++

/datum/wander_attractor/proc/Unsubscribe()
	subs--
	if(subs <= 0)
		SSmobs.wander_attractors.Remove(ID)

/datum/wander_attractor/proc/IsExpired()
	return world.time > die_time

/datum/wander_attractor/proc/IsThatMoreIntense(atom/doer, intensity)
	var/turf/me = get_origin()
	if(!T)
		SSmobs.wander_attractors.Remove(ID)
		return FALSE
	var/turf/them = get_turf(doer)
	if(!them)
		return FALSE
	var/distance = GET_DIST_EUCLIDEAN(them, me)
	if(distance > area_of_effect)
		return FALSE
	var/modulated_intensity = SSmobs.modulate_intensity_by_distance(distance, intensity, area_of_effect)
	return modulated_intensity > intensity

/datum/wander_attractor/proc/get_origin()
	var/turf/T = locate(my_x, my_y, my_z)
	return T


