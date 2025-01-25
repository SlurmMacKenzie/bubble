extends Node2D

enum EOrbitPhysicsType {DIST_SQR,DIST,CONST} 

@export var ghostScene:PackedScene
var spawnedGhostNodes:Array

@export var bSimulate:bool = true
@export var dayTimeStep:float = 1.0
@export var simulationStepsPerDay:float = 10.0 # how many steps to simulate within a day
@export var orbitPhysicsType:EOrbitPhysicsType = EOrbitPhysicsType.DIST_SQR
@export var drag:float = 0.99 #node: this is lazily added per step. Changing the # steps per day with this != 1.0 will change the trajectory.

# These are guesses for testing
@export var earthRadius:float = 60.0
@export var meteoroidRadius:float = 0.0
var collisionDistanceSqr:float;


@export var gravityStrengthMult:float = 100.0

@export var earthNode:Node2D
var gravityCentrePos:Vector2
var gravityCentreLocalPos:Vector2


# Simulation sanity limits
@export var maxSimulationDays:int = 10
# should also do a max distance from the screen centre, etc.

# Don't think I can pass by ref. Extending scope for step variables here for access across class:
var stepPos:Vector2;
var stepVel:Vector2;

func _ready() -> void:
	stepPos = global_position;
	stepVel = Vector2.ZERO;
	if earthNode:
		gravityCentrePos = earthNode.position
	else:
		gravityCentrePos = get_viewport_rect().size / 2
	
	for day in range(maxSimulationDays):
		var newGhost:Node2D = ghostScene.instantiate()
		add_child(newGhost)
		newGhost.position = global_position
		newGhost.visible = false
		spawnedGhostNodes.append(newGhost)


func _process(delta: float) -> void:
	if bSimulate:
		update_simulation_visual()

func update_simulation_visual() -> void:
	# here so that we can easily move things in debug mode
	gravityCentreLocalPos = to_local(gravityCentrePos)
	collisionDistanceSqr = (earthRadius + meteoroidRadius)*(earthRadius + meteoroidRadius);

	var launchDirection:Vector2 = %LaunchDirection.position
	stepPos = launchDirection
	stepVel = launchDirection / dayTimeStep

	var pos_list:PackedVector2Array = PackedVector2Array() # can set size here?
	var simulationTimeStep:float = dayTimeStep / simulationStepsPerDay;
	
	var stepI:int = 0

	pos_list.append(Vector2.ZERO)
	pos_list.append(stepPos)
	# update this to a while loop with exit conditions
	var bCollided:bool = false
	for ghost in spawnedGhostNodes:
		for step in range(simulationStepsPerDay):
			if !bCollided:
				bCollided = step_simulation(simulationTimeStep, stepI)
				pos_list.append(stepPos)
			stepI +=1
			# if bCollided: break??
		ghost.position = stepPos
		ghost.visible = !bCollided
	
	%LaunchSimulationLine.points = pos_list

# Returns true if impact
func step_simulation(timeStep: float, stepI: int) -> bool:
	#nice to have: if the distance is > some delta, step towards it in multiple stages
	
	var toGravityCentre:Vector2 = gravityCentreLocalPos - stepPos
	var toGravityCentreDistSqr = toGravityCentre.length_squared()
	
	if toGravityCentreDistSqr < collisionDistanceSqr:
		print_debug(stepI)
		return true
		#if we collided, we should go back and find the point of collision
	
	var gravityStrength:float = gravityStrengthMult
	match orbitPhysicsType:
		EOrbitPhysicsType.DIST_SQR: # newtonian physics
			gravityStrength = gravityStrengthMult / toGravityCentreDistSqr
		EOrbitPhysicsType.DIST:
			gravityStrength = gravityStrengthMult / toGravityCentre.length()
		EOrbitPhysicsType.CONST:
			gravityStrength = gravityStrengthMult
	
	# Gravity
	var gravityForce:Vector2 = (gravityCentreLocalPos - stepPos) * gravityStrength
	
	# Drag
	var dragForce:Vector2 = Vector2.ZERO
	if stepVel.length_squared() > 0.01:
		dragForce = stepVel*stepVel * drag * -stepVel.normalized()
	
	var externalForcesAccumulated:Vector2 = gravityForce + dragForce
	
	stepVel += externalForcesAccumulated * timeStep
	stepPos += stepVel * timeStep
	
	return false
