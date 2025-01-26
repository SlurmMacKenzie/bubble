extends AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.game_state_changed.connect(_playSound)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _playSound():
	if(GameState.current_state == GameState.GAME_STATE.ASTEROID):
		play()
