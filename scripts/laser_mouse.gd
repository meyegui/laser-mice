@tool
class_name LaserMouse
extends CharacterBody2D

const SPEED: float = 480.0 # px/s
const SHOOT_RATE: int = 150 # milliseconds
const DAMAGE_THRESHOLD: int = 1500 # milliseconds
const DYING_SPEED: float = 4.0
const TRIPLE_LASER_ANGLE: float = deg_to_rad(15)

@export var player_id: int = 0

var spawn_point: Vector2
var spawn_rotation: float

var axes: Dictionary

var health: int = 3:
	get:
		return health

	set(value):
		health = value if value >= 0 else 0

var hurting: bool = false

var killed_by: String
var killed_with: String

var cheese: Cheese

var last_shot: int = -SHOOT_RATE
var last_hurt: int = -DAMAGE_THRESHOLD

var _abilities: Dictionary = {
	"TRIPLE_LASER": false,
}

@onready var illustration: Node2D = $Illustration
@onready var laser_source: Node2D = $LaserSource
@onready var hp: Node2D = $HP
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var pew_sound_player: AudioStreamPlayer = $PewSoundPlayer

func _ready() -> void:
	if not Engine.is_editor_hint():
		# Record spawn position
		spawn_point = global_position
		spawn_rotation = global_rotation

		# Set up axes
		for axis: String in ["up", "left", "down", "right"]:
			axes[axis] = "player%d_%s" % [player_id, axis]

	# Color HP & lasers according to player ID
	var color := Common.get_color(player_id)

	hp.modulate = color
	illustration.get_node("Tail").modulate = color
	laser_source.modulate = color

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var direction := Vector2(
		Input.get_axis(axes["left"], axes["right"]),
		Input.get_axis(axes["up"], axes["down"]),
	).normalized()

	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# deadmau5
	if health == 0:
		die(delta)

	if Common.is_game_over():
		return

	# Make the mouse look in the right direction
	if not direction.is_zero_approx():
		rotation = direction.angle() + deg_to_rad(90)

	# Make the mouse move
	move_and_slide()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Fix positioning of health points
	hp.global_rotation = 0

	if Common.is_game_over():
		return

	var shoot_action := "player%d_shoot" % player_id
	if Input.is_action_just_pressed(shoot_action):
		shoot(true)
	elif Input.is_action_pressed(shoot_action):
		shoot()

func shoot(force: bool=false) -> void:
	var now := Time.get_ticks_msec()

	# Limit the shooting rate
	if (not force) and (now - last_shot < SHOOT_RATE):
		return

	# Mice can't shoot while holding the cheese
	if cheese != null:
		return

	# Play "pew-pew!" sound
	pew_sound_player.play()

	# Instantiate laser beam
	last_shot = now
	var pew_pew: LaserBeam = LaserBeam.make(
		name,
		laser_source.modulate,
		global_position,
		rotation
	)
	Common.level.add_child(pew_pew)

	if _abilities["TRIPLE_LASER"]:
		pew_pew = LaserBeam.make(
			name,
			laser_source.modulate,
			global_position,
			rotation - TRIPLE_LASER_ANGLE
		)
		Common.level.add_child(pew_pew)

		pew_pew = LaserBeam.make(
			name,
			laser_source.modulate,
			global_position,
			rotation + TRIPLE_LASER_ANGLE
		)
		Common.level.add_child(pew_pew)

func hurt(attacker: String, weapon: String, power: int) -> void:
	var now := Time.get_ticks_msec()
	if now - last_hurt < DAMAGE_THRESHOLD:
		return

	health -= power
	last_hurt = now
	if health == 0:
		killed_by = attacker
		killed_with = weapon

	# Update health bars
	var i := 1
	for life: Node in hp.get_children():
		life.visible = health >= i
		i += 1

	# Drop the cheese
	if cheese != null:
		cheese.drop()
		cheese = null

	# Play hurt animation
	hurting = true
	animation.play("Hurt")
	await get_tree().create_timer(DAMAGE_THRESHOLD / 1000.0).timeout
	animation.play("RESET")
	hurting = false

func die(delta: float) -> void:
	var new_scale := move_toward(scale.x, 0, DYING_SPEED * delta)
	scale = Vector2(new_scale, new_scale)

	if (scale.x <= 0.05 or scale.y <= 0.05):
		print("%s was killed by %s using %s!" % [
			name,
			killed_by,
			killed_with,
		])

		# Respawn
		global_position = spawn_point
		global_rotation = spawn_rotation
		health = 3
		scale = Vector2(1, 1)

func grant_ability(ability: String) -> void:
	_abilities[ability] = true

func revoke_ability(ability: String) -> void:
	_abilities[ability] = false

@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
static func spawn(
	player_id: int,
	position: Vector2,
	rotation: float,
	name: String
) -> LaserMouse:
	var new_mouse: LaserMouse = load("res://scenes/laser_mouse.tscn").instantiate()
	new_mouse.player_id = player_id
	new_mouse.global_position = position
	new_mouse.global_rotation = rotation
	new_mouse.name = name

	return new_mouse
