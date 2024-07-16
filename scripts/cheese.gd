class_name Cheese
extends Area2D

var holder: LaserMouse:
	get:
		return holder

	set(value):
		holder = value
		if value != null:
			call_deferred("reparent", value)
			value.cheese = self
		else:
			call_deferred("reparent", get_tree().current_scene)

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if not body is LaserMouse:
		return

	if body.hurting:
		return

	if holder == null:
		print("%s picked up the cheese" % body.name)
		holder = body

func drop() -> void:
	if holder == null:
		return

	print("%s dropped the cheese" % holder.name)
	holder = null
