extends Node2D

var bubble:Bubble = null
var ship:Ship
var velocity:float = 0.0
var bubble_count:int = 3

func _ready() -> void:
	ship = owner
	GameState.connect("game_state_changed", on_game_state_changed)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grow_bubble"):
		if !bubble and bubble_count > 0:
			var b = load("res://prefab/bubble/bubble.tscn")
			bubble = b.instantiate()
			ship.owner.add_child(bubble)
			$BubbleEmitter_Sound.play()
			bubble_count -= 1
			ship.update_sprite(bubble_count, true)
			%bubble_emitted.emitting = true

func _physics_process(delta: float) -> void:
	if bubble and !bubble.detached:
		bubble.update_position(ship.position + Vector2.UP.rotated(ship.rotation) * (bubble.radius + 30))
		bubble.osc_force = remap(owner.velocity.length(), 0, 300, 0, 0.05)
	if bubble and bubble.detached:
		bubble = null

func on_game_state_changed():
	if GameState.current_state == GameState.GAME_STATE.ASTEROID:
		bubble_count = 3
		ship.update_sprite(bubble_count)
