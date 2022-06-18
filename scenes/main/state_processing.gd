extends Node2D

var world_state = {}

func _physics_process(delta):
	if not get_parent().player_state_collection.empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("t")
		world_state["t"] = OS.get_system_time_msecs()
		# verifications
		# anti cheat
		# cuts ( chunking / maps )
		# physics checks
		# anything else that must be done
		get_parent().send_world_state(world_state)
