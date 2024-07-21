class_name StartScreen
extends Node

const GAME: PackedScene = preload ("res://scenes/game.tscn")

@onready var start_button: Button = $StartButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	start_button.pressed.connect(on_start_pressed)
	quit_button.pressed.connect(on_quit_pressed)

	start_button.grab_focus()

func on_start_pressed() -> void:
	Common.level = load("res://levels/level_01.tscn").instantiate()
	get_tree().change_scene_to_packed(GAME)

func on_quit_pressed() -> void:
	get_tree().quit()
