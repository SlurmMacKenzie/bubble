extends Node2D

#@export var meteoroid:Node2D
var meteoroidScene: PackedScene = load("res://prefab/Meteoroid/meteoroid.tscn")
var spawnedMeteoroidNodes:Array

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
	var newLaunchVelocity:Vector2 = (get_viewport_rect().size / 2) - global_position
	newLaunchVelocity = newLaunchVelocity.normalized()
	newLaunchVelocity = newLaunchVelocity.rotated(deg_to_rad(angle)) * speed
	launchVelocity = newLaunchVelocity

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
			closestMeteoroidPos = meteoroid.global_position
	
	return closestMeteoroidPos
			
