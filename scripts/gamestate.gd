extends Node

enum GAME_STATE {SHIP = 0, ASTEROID = 1}

var current_state = GAME_STATE.SHIP
var day_count = 0
var shield_position:Vector2
var shield_angle_extent:float

signal game_started
signal game_state_changed
signal day_incremented
signal take_damage(damage)
signal meteoroid_destroyed
signal shieldSuccessful
signal planet_death_were_all_doomed
signal update_health_bar(health)

func _changeState():
	if(current_state == GAME_STATE.SHIP):
		current_state = GAME_STATE.ASTEROID
	else:
		current_state = GAME_STATE.SHIP

func _setState(value: GAME_STATE):
	current_state = value

func _incrementDay():
	day_count += 1
	day_incremented.emit()
