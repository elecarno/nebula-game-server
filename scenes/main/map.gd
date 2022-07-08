extends Node2D

var enemy_id_counter = 1
var enemy_max = 2
var enemy_types = ["auto_turret"]
var enemy_spawn_points = [Vector2(-500, -100), Vector2(-510, -100)]
var open_locations = [0, 1]
var occupied_locations = {}
var enemy_list = {}

func _ready():
	var timer = Timer.new()
	timer.wait_time = 3
	timer.autostart = true
	timer.connect("timeout", self, "spawn_enemy")
	self.add_child(timer)

func spawn_enemy():
	if enemy_list.size() >= enemy_max:
		pass
	else:
		randomize()
		var type = enemy_types[randi() % enemy_types.size()]
		var rng_location_index = randi() % open_locations.size()
		var location = enemy_spawn_points[open_locations[rng_location_index]]
		occupied_locations[enemy_id_counter] = open_locations[rng_location_index]
		open_locations.remove(rng_location_index)
		enemy_list[enemy_id_counter] = {"enemy_type": type, "enemy_location": location, "enemy_max_hp": 100, "enemy_hp": 100, "enemy_state": "idle", "timeout": 1}
		enemy_id_counter += 1
	for enemy in enemy_list.keys():
		if enemy_list[enemy]["enemy_state"] == "dead":
			if enemy_list[enemy]["timeout"] == 0:
				enemy_list.erase(enemy)
			else:
				enemy_list[enemy]["timeout"] = enemy_list[enemy]["timeout"] - 1

func npc_hit(enemy_id, damage):
	if enemy_list[enemy_id]["enemy_hp"] <= 0:
		pass
	else:
		enemy_list[enemy_id]["enemy_hp"] = enemy_list[enemy_id]["enemy_hp"] - damage
		if enemy_list[enemy_id]["enemy_hp"] <= 0:
			enemy_list[enemy_id]["enemy_state"] == "dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)
