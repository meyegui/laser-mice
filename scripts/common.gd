@tool
extends Node

var game_over: bool = false
var level: Node2D

func get_color(player_id: int) -> Color:
	var color: Color
	match player_id:
		0: color = Color(0.3, 0.3, 1.0) # blue
		1: color = Color(1.0, 0.3, 0.3) # red
		2: color = Color(0.3, 1.0, 0.3) # green
		3: color = Color(1.0, 0.3, 1.0) # fuchsia

	return color
