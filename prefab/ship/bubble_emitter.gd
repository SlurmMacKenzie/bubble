extends Node2D

var bubble:Bubble = null
var ship:Ship
var velocity:float = 0.0

func _ready() -> void:
	ship = owner
	GameState.connect("game_state_changed", on_game_state_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grow_bubble"):
		if !bubble and Bubblemanager.bubble_count > 0:
			var b = load("res://prefab/bubble/bubble.tscn")
			bubble = b.instantiate()
			ship.owner.add_child(bubble)
			var pos:Vector2 = get_bubble_position()
			bubble.update_position(pos)
			bubble.set_pop_locaction(MeteoroidLauncher.getClosestMeteorPos(bubble.global_position))
			$BubbleEmitter_Sound.play()
			Bubblemanager.bubble_count -= 1
			ship.update_sprite(Bubblemanager.bubble_count, true)
			%bubble_emitted.emitting = true
			

func get_bubble_position() -> Vector2:
	return ship.position + Vector2.UP.rotated(ship.rotation) * (bubble.radius + 30)
	
	
func _physics_process(delta: float) -> void:
	if bubble and !bubble.detached:
		bubble.update_position(ship.position + Vector2.UP.rotated(ship.rotation) * (bubble.radius + 30))
		bubble.osc_force = remap(owner.velocity.length(), 0, 300, 0, 0.05)
	if bubble and bubble.detached:
		bubble = null

func on_game_state_changed():
	if GameState.current_state == GameState.GAME_STATE.ASTEROID:
		Bubblemanager.bubble_count = Bubblemanager.bubble_limit
		ship.update_sprite(Bubblemanager.bubble_count)
