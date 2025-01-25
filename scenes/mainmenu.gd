extends Control
@onready var main = $"../"
@onready var play_button_audio = $VBoxContainer/Play/PlayButton_Sound
@onready var quit_button_audio = $VBoxContainer/Quit/QuitButton_Sound

func _on_play_pressed() -> void:
	play_button_audio.play()
	await (play_button_audio.finished)
	get_tree().change_scene_to_file("res://scenes/main.tscn") # Replace with function body.

func _on_quit_pressed() -> void:
	quit_button_audio.play()
	await(quit_button_audio.finished)
	get_tree().quit()

func _on_resume_pressed() -> void:
	main.pauseMenu()
