SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOBS
	flags = SS_KEEP_TIMING | SS_NO_INIT
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	wait = (2 SECONDS)

	var/list/currentrun = list()
	var/static/list/clients_by_zlevel[][]
	var/static/list/dead_players_by_zlevel[][] = list(list()) // Needs to support zlevel 1 here, MaxZChanged only happens when z2 is created and new_players can login before that.
	var/static/list/cubemonkeys = list()
	var/static/list/cheeserats = list()
	var/buggy_mob_running_away = FALSE

	var/there_is_no_escape = FALSE // there is escape
	var/debug_no_icon_2_html = FALSE
	var/debug_everyone_has_robuster_searching = FALSE

	var/distance_where_a_player_needs_to_be_in_for_npcs_to_fight_other_npcs = 12

	var/debug_disable_mob_ceasefire = FALSE // this feature sucks

/datum/controller/subsystem/mobs/stat_entry(msg)
	msg = "P:[length(GLOB.mob_living_list)]"
	return ..()

/datum/controller/subsystem/mobs/proc/MaxZChanged()
	if (!islist(clients_by_zlevel))
		clients_by_zlevel = new /list(world.maxz,0)
		dead_players_by_zlevel = new /list(world.maxz,0)
	while (clients_by_zlevel.len < world.maxz)
		clients_by_zlevel.len++
		clients_by_zlevel[clients_by_zlevel.len] = list()
		dead_players_by_zlevel.len++
		dead_players_by_zlevel[dead_players_by_zlevel.len] = list()

/datum/controller/subsystem/mobs/fire(resumed = 0)
	var/seconds = wait * 0.1
	if (!resumed)
		src.currentrun = GLOB.mob_living_list.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	var/times_fired = src.times_fired
	while(currentrun.len)
		var/mob/living/L = currentrun[currentrun.len]
		currentrun.len--
		if(L)
			L.Life(seconds, times_fired)
		else
			GLOB.mob_living_list.Remove(L)
		if (MC_TICK_CHECK)
			return

/* deprecatad */
/datum/controller/subsystem/mobs/proc/mob_spawned(mob/living/mob)

/datum/controller/subsystem/mobs/proc/mob_despawned(mob/living/mob)

/datum/controller/subsystem/mobs/proc/get_mob_tally(mob/living/mob)

/datum/controller/subsystem/mobs/proc/is_extinct(mobpath)

/datum/controller/subsystem/mobs/proc/get_existing_mob_paths(mob/mobpath)
	return typesof(mobpath)
/* end deprocatid */
