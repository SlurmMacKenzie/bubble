extends Control
@onready var main = $"../"
@onready var play_button_audio = $VBoxContainer/Play/PlayButton_Sound
@onready var quit_button_audio = $VBoxContainer/Quit/QuitButton_Sound

func _on_play_pressed() -> void:
	var play_button_audio = $VBoxContainer/Play/PlayButton_Sound
	play_button_audio.play()
	await (play_button_audio.finished)
	$".".hide()
	$"../Intro".show()

func _on_quit_pressed() -> void:
	quit_button_audio.play()
	await(quit_button_audio.finished)
	get_tree().quit()

func _on_resume_pressed() -> void:
	play_button_audio.play()
	await(play_button_audio.finished)
	main.pauseMenu()
