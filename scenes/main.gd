extends Node2D
var imgui:bool = false
var fullscreen:bool = false

#Scene Helper variables
@onready var ship = $Ship
@onready var planet = $Planet

#Pause menu variables
@onready var pause_menu =  $PauseMenu
var is_paused = false

func _on_ready() -> void:
	GameState.game_state_changed.connect(onGameStateChanged)
	GameState.game_started.emit()


		
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("debug"):
		imgui = !imgui
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
	if Input.is_action_just_pressed("debug_changestate"):
		GameState._changeState()
		GameState.game_state_changed.emit()
	if Input.is_action_just_pressed("fullscreen"):
		if !fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			fullscreen = true
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			fullscreen = false

func pauseMenu():
	if is_paused:
		pause_menu.hide()
		Engine.time_scale = 1
	else:
		pause_menu.show()
		Engine.time_scale = 0
	is_paused = !is_paused
	
func onGameStateChanged():
	if(GameState.current_state == GameState.GAME_STATE.SHIP):
		ship.show()
	else:
		ship.hide()
