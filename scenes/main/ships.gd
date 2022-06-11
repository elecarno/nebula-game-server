extends Node2D

func fetch_shipdata(ship_name, player_id):
	var player_container = get_node("../" + str(player_id)) # for reference to other player data
	var shipdata = serverdata.shipdata[ship_name]
	return shipdata
