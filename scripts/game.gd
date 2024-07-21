extends Control

@onready var viewports: Array[SubViewport] = [
	$HBoxContainer/SubViewportContainer/SubViewport,
	$HBoxContainer/SubViewportContainer2/SubViewport,
]

@onready var cameras: Array[Camera2D] = [
	$HBoxContainer/SubViewportContainer/SubViewport/Camera2D,
	$HBoxContainer/SubViewportContainer2/SubViewport/Camera2D,
]

func _ready() -> void:
	if Common.level == null:
		assert(false, "No level is loaded")

	set_level(Common.level, true)

	# Share the world across viewports
	if count_players() == 0:
		assert(false, "No players are set")

	viewports[1].world_2d = viewports[0].world_2d

	_position_cameras()

func _process(_delta: float) -> void:
	_position_cameras()

# Make cameras track players
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

func set_level(level: Node2D, force: bool=false) -> void:
	var current_level: Node2D = $HBoxContainer/SubViewportContainer/SubViewport/Level

	if not force:
		if Common.level == level:
			print("set_level: cancel because same")
			return

		if level == null:
			print("set_level: cancel because null")
			return

	Common.level = level

	if level != null:
		Common.level.name = "Level"
		current_level.free()
		$HBoxContainer/SubViewportContainer/SubViewport.add_child(Common.level)

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
