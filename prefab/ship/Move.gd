extends Node
var ship:Ship

var angular_velocity:float = 0.0
var linear_velocity:Vector2 = Vector2.ZERO
const linear_velocity_deceleration:float = 0.1
const angular_velocity_deceleration:float = 0.1

const max_angular_velocity = 15.0
const max_linear_velocity = 1000.0

func _ready() -> void:
	ship = owner

func _physics_process(delta: float) -> void:
	var movement:Vector2 = get_movement_vector()
	
	if movement.y > 0:
		%bubble_trail.emitting = true
	else:
		%bubble_trail.emitting = false
	linear_velocity += movement.y * Vector2.UP.rotated(ship.rotation) * max_linear_velocity * delta
	linear_velocity = linear_velocity.lerp(Vector2.ZERO, linear_velocity_deceleration)
	ship.set_velocity(linear_velocity)
	ship.move_and_slide()
	
	angular_velocity += movement.x * max_angular_velocity * delta 
	angular_velocity = lerpf(angular_velocity, 0.0, angular_velocity_deceleration)
	ship.rotation += angular_velocity * delta

func get_movement_vector() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("thursters")
	)
