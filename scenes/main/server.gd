extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 250

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
	
func _player_disconnected(player_id):
	print("player " + str(player_id) + " disconnected")

# called by `rpc_id()` from client
remote func fetch_shipdata(ship_name, requester):
	print("shipdata requested")
	var player_id = get_tree().get_rpc_sender_id() # `get_rpc_sender_id()` gets the id of the instance who made the intial call
	var shipdata = get_node("ships").fetch_shipdata(ship_name)
	rpc_id(player_id, "return_shipdata", shipdata, requester) # `rpc_id()` calls `remote func return_shipdata()` on the client
	print("sending data for ship: " + str(ship_name) + " to player")
