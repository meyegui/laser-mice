extends Area2D

func _ready() -> void:
	modulate.r = randf()
	modulate.g = randf()
	modulate.b = randf()

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is LaserMouse:
		return

	body.grant_ability("TRIPLE_LASER")
	queue_free()
