extends Node

var shipdata
var playerdata
var default_data = {
	"credits": 2500,
	"pos": {
		"x": -648,
		"y": -31
	},
	"stats": {
		"hp": 100,
		"oxygen": 100,
		"nitrogen": 100,
		"hunger": 100,
		"helmet": true
	},
	"ships": {},
}

func _ready():
	var shipdata_file = File.new()
	shipdata_file.open("res://data/shipdata.json", File.READ)
	var shipdata_json = JSON.parse(shipdata_file.get_as_text())
	shipdata_file.close()
	shipdata = shipdata_json.result
	
	var playerdata_file = File.new()
	playerdata_file.open("res://data/playergamedata.json", File.READ)
	var playerdata_json = JSON.parse(playerdata_file.get_as_text())
	playerdata_file.close()
	playerdata = playerdata_json.result
	print("initialised ship and player data")
	
func write_playerdata(playeruser, player_id):
	playerdata[playeruser] = get_parent().get_node("server/" + str(player_id)).playerdata
	var file = File.new()
	file.open("res://data/playergamedata.json", File.WRITE)
	file.store_line(to_json(playerdata))
	file.close()

func write_playerdata_update(playeruser, player_id, newdata):
	playerdata[playeruser] = newdata
	print(str(playerdata))
	var file = File.new()
	file.open("res://data/playergamedata.json", File.WRITE)
	file.store_line(to_json(playerdata))
	file.close()
