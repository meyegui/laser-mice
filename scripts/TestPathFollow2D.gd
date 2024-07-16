extends PathFollow2D

@export var speed: float = 200.0

func _process(delta: float) -> void:
	progress += speed * delta
