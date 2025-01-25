extends Node

enum GAME_STATE {SHIP = 0, ASTEROID = 1}

var current_state = GAME_STATE.SHIP
signal game_state_changed

func _changeState():
	if(current_state == GAME_STATE.SHIP):
		current_state = GAME_STATE.ASTEROID
	else:
		current_state = GAME_STATE.SHIP

func _setState(value: GAME_STATE):
	current_state = value
