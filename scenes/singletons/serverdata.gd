extends Node

var shipdata

func _ready():
	var shipdata_file = File.new()
	shipdata_file.open("res://data/shipdata.json", File.READ)
	var shipdata_json = JSON.parse(shipdata_file.get_as_text())
	shipdata_file.close()
	shipdata = shipdata_json.result
