@tool
extends Control

@onready var players: Dictionary = {
	0: {
		viewport = $HBoxContainer/SubViewportContainer/SubViewport,
		camera = $HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Level/Players/Guigui,
	},
	1: {
		viewport = $HBoxContainer/SubViewportContainer2/SubViewport,
		camera = $HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
		player = $HBoxContainer/SubViewportContainer/SubViewport/Level/Players/Pépette,
	},
}

func _ready() -> void:
	Common.level = $HBoxContainer/SubViewportContainer/SubViewport/Level

	# Share the world across viewports
	players[1].viewport.world_2d = players[0].viewport.world_2d

	_position_cameras()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_position_cameras()

# Make cameras track players
func _position_cameras() -> void:
	for p: Dictionary in players.values():
		p.camera.global_position = p.player.global_position
