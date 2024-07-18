class_name Cheese
extends Area2D

var holder: LaserMouse

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
		reparent.call_deferred(holder)
		holder.cheese = self

func drop() -> void:
	if holder == null:
		return

	print("%s dropped the cheese" % holder.name)
	holder.cheese = null
	holder = null
	reparent.call_deferred(get_tree().current_scene)
