class_name GameOverScreen
extends Control

var winner_name: String = "Player"
var winner_id: int

@onready var background: ColorRect = $Background
@onready var winner: Label = $Winner
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var next_level_button: Button = $NextLevelButton
@onready var play_again_button: Button = $PlayAgainButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	_initialize()

	# Connect signals
	visibility_changed.connect(_on_visibility_changed)
	next_level_button.pressed.connect(_on_next_level_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _initialize() -> void:
	# Set up text and color
	winner.text = "%s wins!" % winner_name
	background.modulate = Common.get_color(winner_id)

	var default_action_button: Button = next_level_button
	if Common.game.current_level == Common.max_level_id:
		next_level_button.disabled = true
		default_action_button = quit_button

	# Autofocus default action
	default_action_button.grab_focus()

	# Play animations
	_animate()

func _animate() -> void:
	animation_player.play("GameOver")
	$Boom1.emitting = true
	$Boom2.emitting = true
	$Boom3.emitting = true

func _on_visibility_changed() -> void:
	if visible:
		_initialize()
	else:
		_reset_animation()

func _on_next_level_pressed() -> void:
	Common.game.next_level()

func _on_play_again_pressed() -> void:
	Common.game._load_level()
	Common.hide_game_over_screen()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _reset_animation() -> void:
	animation_player.play("RESET")
