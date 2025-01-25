extends Node2D

var bubble:Bubble = null
var ship:Ship
var velocity:float = 0.0

func _ready() -> void:
	ship = owner
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grow_bubble"):
		if !bubble:
			var b = load("res://prefab/bubble/bubble.tscn")
			bubble = b.instantiate()
			ship.owner.add_child(bubble)

func _physics_process(delta: float) -> void:
	if bubble and !bubble.detached:
		bubble.update_position(ship.position + Vector2.UP.rotated(ship.rotation) * (bubble.radius + 30))
		bubble.osc_force = remap(owner.velocity.length(), 0, 300, 0, 0.05)
	if bubble and bubble.detached:
		bubble = null
