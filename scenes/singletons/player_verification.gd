extends Node2D

onready var player_container_scene = preload("res://scenes/instances/player_container.tscn")

func start(player_id):
	create_player_container(player_id)
	
func create_player_container(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	fill_player_container(player_container)
	
func fill_player_container(player_container):
	print(player_container)
	player_container.player_stats = serverdata.test_data.stats
