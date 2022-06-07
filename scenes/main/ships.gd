extends Node2D

func fetch_shipdata(ship_name):
	var shipdata = serverdata.shipdata[ship_name]
	return shipdata
