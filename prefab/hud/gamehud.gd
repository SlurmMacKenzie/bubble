extends Control
@onready var timerLabel = $HBoxContainer/TimerLabel
@onready var timer = $Timer
@onready var dayLabel = $"HBoxContainer/Day Label"
@onready var resourceLabel = $HBoxContainer/HBoxContainer/resourcelabel

func _process(delta: float) -> void:
	timerLabel.text = str($Timer.time_left as int)
	resourceLabel.text = str(Bubblemanager.bubble_count)
	$MeteroidCount.text = "Meteroids Approaching the planet: %s" % MeteoroidLauncher.spawnedMeteoroidNodes.size()
	
func _on_button_pressed() -> void:
	timerLabel.show()
	GameState.current_state = GameState.GAME_STATE.ASTEROID
	GameState.game_state_changed.emit()
	timer.start()

func _on_timer_timeout() -> void:
	timerLabel.hide()
	GameState._incrementDay()
	dayLabel.text = str("Day %d" % GameState.day_count)
	GameState.current_state = GameState.GAME_STATE.SHIP
	GameState.game_state_changed.emit()
