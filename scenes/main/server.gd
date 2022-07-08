extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 250

var expected_tokens = []
var player_state_collection = {}

onready var player_verification_process = get_node("player_verification")
onready var ship_functions = get_node("ships")

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("server started")

func _player_connected(player_id):
	print("player " + str(player_id) + " connected")
	player_verification_process.start(player_id)
	
func _player_disconnected(player_id):
	print("player " + str(player_id) + " disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		rpc_id(0, "despawn_player", player_id)
	
func _on_token_expiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1 ,-1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)
				
remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")
	
remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token)
	
func return_token_verification_results(player_id, result):
	rpc_id(player_id, "return_token_verification_results", result)
	if result == true:
		rpc_id(0, "spawn_new_player", player_id, Vector2(0, 0))
		
remote func recieve_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["t"] < player_state["t"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state

func send_world_state(world_state):
	rpc_unreliable_id(0, "recieve_world_state", world_state)
	
remote func attack(positon, rotation_deg, rotation, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(0, "recieve_attack", position, rotation_deg, rotation, spawn_time, player_id)

# called by `rpc_id()` from client
remote func fetch_shipdata(ship_name, requester):
	print("shipdata requested")
	var player_id = get_tree().get_rpc_sender_id() # `get_rpc_sender_id()` gets the id of the instance who made the intial call
	var shipdata = ship_functions.fetch_shipdata(ship_name, player_id)
	rpc_id(player_id, "return_shipdata", shipdata, requester) # `rpc_id()` calls `remote func return_shipdata()` on the client
	print("sending data for ship: " + str(ship_name) + " to player")

remote func send_npc_hit(enemy_id, damage):
	get_node("map").npc_hit(enemy_id, damage)

remote func fetch_playerdata(playeruser):
	var player_id = get_tree().get_rpc_sender_id()
	get_node(str(player_id)).playeruser = playeruser
	var playerdata
	var create = true
	for user in serverdata.playerdata:
		if user == playeruser:
			playerdata = serverdata.playerdata[playeruser]
			create = false
			print("loaded data" + str(serverdata.playerdata[playeruser]) + " for " + str(player_id) + ", user: " + str(playeruser))
	if create == true:
		playerdata = serverdata.default_data
		serverdata.write_playerdata(playeruser, player_id)
		print("created player data entry for " + str(player_id) + ", user: " + str(playeruser))
	rpc_id(player_id, "return_playerdata", playerdata)

remote func write_playerdata_update(playeruser, newdata):
	var player_id = get_tree().get_rpc_sender_id()
	serverdata.write_playerdata_update(playeruser, player_id, newdata)
