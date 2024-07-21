@tool
class_name Home
extends Area2D

@export var player_id: int

@onready var illustration: ColorRect = $Illustration
@onready var win_sound_player: AudioStreamPlayer2D = $WinSoundPlayer

func _ready() -> void:
	# Connect signals
	area_entered.connect(on_area_entered)

	# Set color
	var color := Common.get_color(player_id)
	illustration.modulate = color

func on_area_entered(area: Area2D) -> void:
	if not area is Cheese:
		return

	if area.holder == null:
		#print("Cheese entered %s without a holder" % name)
		return

	if player_id != area.holder.player_id:
		return

	print("%s wins! 🎉" % area.holder.name)
	win_sound_player.play() # todo: record "Brrravooo! 👏🏻" audio

	# Show "Game Over" screen
	Common.show_game_over_screen(area.holder.name, area.holder.player_id)
