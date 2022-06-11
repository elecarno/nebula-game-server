extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 250

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
