extends Control

var winner_name: String
var winner_id: int

@onready var background: ColorRect = $Background
@onready var winner: Label = $Winner
@onready var play_again_button: Button = $PlayAgainButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	Common.game_over = true
	background.modulate = Common.get_color(winner_id)
	winner.text = "%s wins!" % winner_name

	play_again_button.pressed.connect(on_play_again_pressed)
	quit_button.pressed.connect(on_quit_pressed)

	play_again_button.grab_focus()

func on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
	Common.game_over = false

func on_quit_pressed() -> void:
	get_tree().quit()
