extends Control

func _process(delta: float) -> void:
	$Label.text = str($Timer.time_left as int)

func _on_button_pressed() -> void:
	$Label.show()
	GameState.current_state = GameState.GAME_STATE.ASTEROID
	GameState.game_state_changed.emit()
	$Timer.start()

func _on_timer_timeout() -> void:
	$Label.hide()
	GameState.current_state = GameState.GAME_STATE.SHIP
	GameState.game_state_changed.emit()
