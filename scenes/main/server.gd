extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 250

var expected_tokens = []

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
	get_node(str(player_id)).queue_free()
	
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

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")
	
remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification_process.verify(player_id, token)
	
func return_token_verification_results(player_id, result):
	rpc_id(player_id, "return_token_verification_results", result)

# called by `rpc_id()` from client
remote func fetch_shipdata(ship_name, requester):
	print("shipdata requested")
	var player_id = get_tree().get_rpc_sender_id() # `get_rpc_sender_id()` gets the id of the instance who made the intial call
	var shipdata = ship_functions.fetch_shipdata(ship_name, player_id)
	rpc_id(player_id, "return_shipdata", shipdata, requester) # `rpc_id()` calls `remote func return_shipdata()` on the client
	print("sending data for ship: " + str(ship_name) + " to player")

remote func fetch_playerstats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = get_node(str(player_id)).player_stats
	rpc_id(player_id, "return_player_stats", player_stats)
