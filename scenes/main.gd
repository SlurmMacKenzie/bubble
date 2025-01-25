extends Node2D
var imgui:bool = false
@onready var pause_menu =  $PauseMenu
var is_paused = false

func _process(delta: float) -> void:
	if imgui:
		Debug.do_imgui()

		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("debug"):
		imgui = !imgui
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu():
	if is_paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	is_paused = !is_paused
	
