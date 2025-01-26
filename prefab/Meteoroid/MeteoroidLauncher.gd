extends Node2D

@export var meteoroid:Node2D

@export var bResimulateLaunch:bool = false
@export var launchVelocity:Vector2 = Vector2.ZERO

@export var randomisedSpeedBounds:Vector2 = Vector2(20.0, 80.0)
@export var randomisedAngleBounds:Vector2 = Vector2(30.0, 120.0) # Angle offset from pointing at planet
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	simulateLaunch()

func _process(delta: float) -> void:
	if bResimulateLaunch:
		simulateLaunch()

func _input(event):
	if Input.is_key_pressed(KEY_R):
		randomiseLaunchParams()
		simulateLaunch()

func randomiseLaunchParams() -> void:
	var speed = rng.randf_range(randomisedSpeedBounds.x, randomisedSpeedBounds.y)
	var angle = rng.randf_range(randomisedAngleBounds.x, randomisedAngleBounds.y)
	if rng.randf() < 0.5:
		angle *= -1.0
	var newLaunchVelocity:Vector2 = (get_viewport_rect().size / 2) - meteoroid.global_position
	newLaunchVelocity = newLaunchVelocity.normalized()
	newLaunchVelocity = newLaunchVelocity.rotated(deg_to_rad(angle)) * speed
	launchVelocity = newLaunchVelocity
	print_debug(speed)
	print_debug(angle)
	print_debug(launchVelocity)

func simulateLaunch() -> void:
	if meteoroid:
		meteoroid.launch(launchVelocity)
		
