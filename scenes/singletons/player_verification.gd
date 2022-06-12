extends Node2D

onready var main_interface = get_parent()
onready var player_container_scene = preload("res://scenes/instances/player_container.tscn")

var awaiting_verification = {}

func start(player_id):
	awaiting_verification[player_id] = {"timestamp": OS.get_unix_time()}
	main_interface.fetch_token(player_id)
	
func verify(player_id, token):
	var token_verification = false
	while OS.get_unix_time() - int(token.right(64)) <= 30:
		if main_interface.expected_tokens.has(token):
			token_verification = true
			create_player_container(player_id)
			awaiting_verification.erase(player_id)
			main_interface.expected_tokens.erase(token)
			break
		else:
			yield(get_tree().create_timer(2), "timeout")
	main_interface.return_token_verification_results(player_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(player_id)
		main_interface.network.disconnect_peer(player_id)
	
func _on_verification_expiration_timeout():
	var current_time = OS.get_unix_time()
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].timestamp
			if current_time - start_time >= 10:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_tree().get_network_connected_peers())
				if connected_peers.has(key):
					main_interface.return_token_verification_results(key, false)
					main_interface.network.disconnect_peer(key)
	print("awaiting verification:")
	print(awaiting_verification)
	
func create_player_container(player_id):
	var new_player_container = player_container_scene.instance()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	var player_container = get_node("../" + str(player_id))
	fill_player_container(player_container)
	
func fill_player_container(player_container):
	print(player_container)
	player_container.player_stats = serverdata.test_data.stats

