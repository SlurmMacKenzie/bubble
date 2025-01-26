extends Node2D

#@export var meteoroid:Node2D
var meteoroidScene: PackedScene = load("res://prefab/Meteoroid/meteoroid.tscn")
var spawnedMeteoroidNodes:Array

@export var bResimulateLaunch:bool = false
@export var launchVelocity:Vector2 = Vector2.ZERO

@export var randomisedSpeedBounds:Vector2 = Vector2(20.0, 80.0)
@export var randomisedAngleBounds:Vector2 = Vector2(30.0, 120.0) # Angle offset from pointing at planet
@export var randomisedLaunchPositionDistanceFromEarthDeadzone = 330.0
@export var randomisedLaunchPositionDistanceFromEdgeDeadzone = 50.0
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	GameState.game_started.connect(_onGameStateChanged)
	#GameState.game_state_changed.connect(_onGameStateChanged)
	pass

func _process(delta: float) -> void:
	if bResimulateLaunch:
		simulateLaunch()

func _input(event):
	if Input.is_key_pressed(KEY_R): #launch new meteoroid with random vel
		randomiseLaunchParams()
		simulateLaunch()
	if Input.is_key_pressed(KEY_E): #launch meteoroid with vel from inspector
		simulateLaunch()
	if Input.is_key_pressed(KEY_Y): #clear all spawned meteoroids
		clearMeteoroids()
	#note: there's also the debug hotkey T which increments the meteoroid pos by 1 day

func randomiseLaunchParams() -> void:
	var speed = rng.randf_range(randomisedSpeedBounds.x, randomisedSpeedBounds.y)
	var angle = rng.randf_range(randomisedAngleBounds.x, randomisedAngleBounds.y)
	if rng.randf() < 0.5:
		angle *= -1.0
	var viewPortRange:Vector2 = get_viewport_rect().size
	var newLaunchVelocity:Vector2 = (viewPortRange / 2) - global_position
	newLaunchVelocity = newLaunchVelocity.normalized()
	newLaunchVelocity = newLaunchVelocity.rotated(deg_to_rad(angle)) * speed
	launchVelocity = newLaunchVelocity
	
	var launchPosition:Vector2 = getRandPositionOnScreen()
	# For now (it's a game jam, cmon) I'm just checking if it's in the dead zone and retrying. Don't want to bias the distbn.
	for i in range(10):
		if launchPosition.distance_squared_to(viewPortRange / 2) < randomisedLaunchPositionDistanceFromEarthDeadzone*randomisedLaunchPositionDistanceFromEarthDeadzone:
			launchPosition = getRandPositionOnScreen()
			#print_debug("Retrying random position: ", i)
			if i >= 10:
				print_debug("Can't find good spawn location")
		
	position = launchPosition

func getRandPositionOnScreen() -> Vector2:
	return 	Vector2( \
			randf_range(randomisedLaunchPositionDistanceFromEdgeDeadzone, \
				get_viewport_rect().size.x - randomisedLaunchPositionDistanceFromEdgeDeadzone), \
			randf_range(randomisedLaunchPositionDistanceFromEdgeDeadzone, \
				get_viewport_rect().size.y - randomisedLaunchPositionDistanceFromEdgeDeadzone))

func simulateLaunch() -> void:
	var newMeteoroid:Node2D = meteoroidScene.instantiate()
	get_parent().add_child.call_deferred(newMeteoroid)
	newMeteoroid.position = position
	spawnedMeteoroidNodes.append(newMeteoroid)
	newMeteoroid.launch.call_deferred(launchVelocity)

func clearMeteoroids() -> void:
	for meteoroid in spawnedMeteoroidNodes:
		meteoroid.queue_free()
	spawnedMeteoroidNodes.clear()

# used by the bubble to see whether it should pop
func getClosestMeteorPos(pos:Vector2) -> Vector2:
	var distSqr:float = INF
	var closestMeteoroidPos = Vector2.INF
	for meteoroid in spawnedMeteoroidNodes:
		var candidateDistSqr:float = (meteoroid.get_current_position() - pos).length_squared()
		if candidateDistSqr < distSqr:
			distSqr = candidateDistSqr
			closestMeteoroidPos = meteoroid.get_current_position()
	
	return closestMeteoroidPos
			
func _onGameStateChanged():
	randomiseLaunchParams()
	simulateLaunch()
