class_name LaserBeam
extends Area2D

const SCENE: PackedScene = preload ("res://scenes/laser_beam.tscn")

const SPEED := 40
const POWER := 1

var _emitter: String
var _direction: Vector2

@onready var _timer: Timer = $Timer

func _ready() -> void:
	name = "LaserBeam"

	# Connect signals
	body_entered.connect(_on_body_entered)
	_timer.timeout.connect(_on_timer_timeout)

	# Set movement _direction
	var orientation := rotation - deg_to_rad(90)
	_direction = Vector2(cos(orientation), sin(orientation))

func _physics_process(_delta: float) -> void:
	position += _direction * SPEED

func _on_body_entered(body: Node2D) -> void:
	if body is TileMap:
		queue_free()
		return

	if not body is LaserMouse:
		return

	# Mice can't hurt themselves
	if body.name == _emitter:
		return

	body.hurt(_emitter, self.name, POWER)

	_timer.stop()
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()

static func make(
	p_emitter: String,
	p_modulate: Color,
	p_position: Vector2,
	p_rotation: float
) -> LaserBeam:
	var pew_pew: LaserBeam = SCENE.instantiate()
	pew_pew._emitter = p_emitter
	pew_pew.modulate = p_modulate # match mouse color
	pew_pew.global_position = p_position
	pew_pew.rotation = p_rotation

	return pew_pew
