class_name Game
extends Control

var current_level: int = 1

@onready var viewports: Array[SubViewport] = [
	$HBoxContainer/SubViewportContainer/SubViewport,
	$HBoxContainer/SubViewportContainer2/SubViewport,
]

@onready var cameras: Array[Camera2D] = [
	$HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
	$HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
]

func _ready() -> void:
	Common.game = self

	_load_level()

	# Share the world across viewports
	if count_players() == 0:
		assert(false, "No players are set")

	viewports[1].world_2d = viewports[0].world_2d

	_position_cameras()

func _process(_delta: float) -> void:
	_position_cameras()

	# @xxx
	if Input.is_key_pressed(KEY_T):
		Common.show_game_over_screen("Guigui", 0)

## Make cameras track players.
func _position_cameras() -> void:
	for i in range(viewports.size()):
		var camera: Camera2D = cameras[i]
		if camera == null:
			print("_position_cameras: cancel because camera %d is null" % i)
			return

		var player: LaserMouse = get_player(i)
		if player == null:
			print("_position_cameras: cancel because player %d is null" % i)
			return

		camera.global_position = player.global_position

## Reset the current level to a new instance.
func _load_level() -> void:
	var scene: PackedScene = load("res://levels/level_%d.tscn" % current_level)
	var level: Node2D = scene.instantiate()
	level.name = "Level"
	$HBoxContainer/SubViewportContainer/SubViewport/Level.free()
	$HBoxContainer/SubViewportContainer/SubViewport.add_child(level)

	Common.level = level
	Common.hide_game_over_screen()

func get_player(player_id: int) -> LaserMouse:
	var players: Node = $HBoxContainer/SubViewportContainer/SubViewport/Level/Players
	for player: Node in players.get_children():
		var laser_mouse: LaserMouse = player as LaserMouse
		if laser_mouse.player_id == player_id:
			return laser_mouse

	return null

func count_players() -> int:
	var players: Node = $HBoxContainer/SubViewportContainer/SubViewport/Level/Players
	return players.get_child_count()

## Loads the next level.
func next_level() -> void:
	current_level += 1
	_load_level()
