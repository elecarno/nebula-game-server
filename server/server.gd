extends Node2D

var network = NetworkedMultiplayerENet.new()
var port = 5000
var max_players = 25

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
