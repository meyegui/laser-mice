extends Node

var game: Game
var level: Node2D
var game_over_screen: GameOverScreen

var max_level_id: int

func _ready() -> void:
	# Count existing level files
	var files := DirAccess.get_files_at("res://levels")
	for f in files:
		if f.begins_with("level_") and f.ends_with(".tscn"):
			max_level_id += 1

func get_color(player_id: int) -> Color:
	var color: Color
	match player_id:
		0: color = Color(0.3, 0.3, 1.0) # blue
		1: color = Color(1.0, 0.3, 0.3) # red
		2: color = Color(0.3, 1.0, 0.3) # green
		3: color = Color(1.0, 0.3, 1.0) # fuchsia

	return color

## Show the "Game Over" screen.
func show_game_over_screen(winner_name: String, winner_id: int) -> void:
	var should_add: bool = false
	if game_over_screen == null:
		game_over_screen = preload ("res://scenes/game_over_screen.tscn").instantiate()
		should_add = true

	game_over_screen.winner_name = winner_name
	game_over_screen.winner_id = winner_id

	if should_add:
		game.get_tree().current_scene.add_child(game_over_screen)

	game_over_screen.visible = true

## Hide the "Game Over" screen.
func hide_game_over_screen() -> void:
	if game_over_screen == null:
		return

	game_over_screen.visible = false

func is_game_over() -> bool:
	if game_over_screen == null:
		return false

	return game_over_screen.visible
