class_name LaserMouse
extends CharacterBody2D

const SPEED: float = 480.0 # px/s
const SHOOT_THRESHOLD: int = 150 # milliseconds
const DAMAGE_THRESHOLD: int = 1500 # milliseconds
const DYING_SPEED: float = 4.0

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

var last_shot: int = -SHOOT_THRESHOLD
var last_hurt: int = -DAMAGE_THRESHOLD

@onready var illustration: Node2D = $Illustration
@onready var laser_source: Node2D = $LaserSource
@onready var hp: Node2D = $HP
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var pew_sound_player: AudioStreamPlayer2D = $PewSoundPlayer
@onready var laser_beam: PackedScene = load("res://scenes/laser_beam.tscn")

func _ready() -> void:
	# Record spawn position
	spawn_point = global_position
	spawn_rotation = global_rotation

	# Set up axes
	for axis: String in ["up", "left", "down", "right"]:
		axes[axis] = "player%d_%s" % [player_id, axis]

	# Color HP & lasers according to player ID
	var color: Color
	match player_id:
		0: color = Color(0.3, 0.3, 1)
		1: color = Color(1, 0.3, 0.3)

	# illustration.modulate = color
	hp.modulate = color
	laser_source.modulate = color

func _physics_process(delta: float) -> void:
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

	# Make the mouse look in the right direction
	if not direction.is_zero_approx():
		rotation = direction.angle() + deg_to_rad(90)

	# deadmau5
	if health == 0:
		die(delta)

	move_and_slide()

func _process(_delta: float) -> void:
	var shoot_action := "player%d_shoot" % player_id
	if Input.is_action_just_pressed(shoot_action):
		shoot(true)
	elif Input.is_action_pressed(shoot_action):
		shoot()

	# Fix positioning of health points
	hp.global_rotation = 0

func shoot(force: bool=false) -> void:
	var now := Time.get_ticks_msec()
	if (not force) and (now - last_shot < SHOOT_THRESHOLD):
		return

	# Play "pew-pew!" sound
	pew_sound_player.play()

	# Instantiate laser beam
	var pew_pew: LaserBeam = laser_beam.instantiate()
	pew_pew.emitter = self.name
	pew_pew.modulate = laser_source.modulate # match mouse color
	pew_pew.global_position = laser_source.global_position
	pew_pew.rotation = rotation
	get_tree().current_scene.add_child(pew_pew)
	last_shot = now

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
		queue_free()

		# Respawn
		var laser_mouse := LaserMouse.spawn(player_id, spawn_point, spawn_rotation, name)
		get_tree().current_scene.add_child(laser_mouse)

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
