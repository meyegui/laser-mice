class_name LaserBeam
extends Area2D

const SPEED := 40
const POWER := 1

var emitter: String
var direction: Vector2

@onready var timer: Timer = $Timer

func _ready() -> void:
	name = "LaserBeam"

	# Connect signals
	body_entered.connect(on_body_entered)
	timer.timeout.connect(on_timer_timeout)

	# Set movement direction
	var orientation := rotation - deg_to_rad(90)
	direction = Vector2(cos(orientation), sin(orientation))

func _physics_process(_delta: float) -> void:
	position += direction * SPEED

func on_body_entered(body: Node2D) -> void:
	if body is TileMap:
		queue_free()
		return

	if not body is LaserMouse:
		return

	# Mice can't hurt themselves
	if body.name == emitter:
		return

	body.hurt(emitter, self.name, POWER)

	timer.stop()
	queue_free()

func on_timer_timeout() -> void:
	queue_free()
