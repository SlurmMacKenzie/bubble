extends Control
@onready var timerLabel = $HBoxContainer/TimerLabel
@onready var timer = $Timer
@onready var dayLabel = $"HBoxContainer/Day Label"
@onready var resourceLabel = $HBoxContainer/HBoxContainer/resourcelabel
@onready var shieldedLabel = $Label
@onready var loseLabel = $LoseLabel

func _ready() -> void:
	GameState.shieldSuccessful.connect(_onShieldSuccessful)
	GameState.planet_death_were_all_doomed.connect(_onPlanetDeath)
	
func _process(delta: float) -> void:
	timerLabel.text = str(ceil($Timer.time_left))
	resourceLabel.text = str(Bubblemanager.bubble_count)
	$MeteroidCount.text = "Meteoroids Approaching the planet: %s" % MeteoroidLauncher.spawnedMeteoroidNodes.size()
	
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

func _onShieldSuccessful():
	shieldedLabel.show()
	$Label/ShieldedTimer.start()

func _on_shieldedtimer_timeout() -> void:
	shieldedLabel.hide() # Replace with function body.
	

func _onPlanetDeath():
	loseLabel.show()
