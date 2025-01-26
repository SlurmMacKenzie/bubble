extends Node2D

enum EOrbitPhysicsType {DIST_SQR,DIST,CONST} 
enum EOrbitDebugViewType {SHOW_ALL,SHOW_CURRENT_AND_ARC,SHOW_CURRENT,HIDE}

@export var launchSimulationLineNode:Node2D
@export var impactSpriteNode:Node2D
@export var launchDebugSpriteNode:Node2D

var ghostScene: PackedScene = load("res://prefab/Meteoroid/meteoroidGhost.tscn")
var spawnedGhostNodes:Array

@export var dayTimeStep:float = 1.0
@export var simulationStepsPerDay:float = 10.0 # how many steps to simulate within a day
@export var orbitPhysicsType:EOrbitPhysicsType = EOrbitPhysicsType.DIST_SQR
@export var drag:float = 0.003

# These are guesses for testing
@export var earthRadius:float = 60.0
@export var meteoroidRadius:float = 0.0
var collisionDistanceSqr:float;

@export var gravityStrengthMult:float = 100.0

var earthNode:Node2D
var gravityCentrePos:Vector2
var gravityCentreLocalPos:Vector2

# Results of calculations we need to run the game. In debugging, we can recalculate every frame
var calculatedDayPositions:PackedVector2Array
var calculatedLineVertices:PackedVector2Array
var calculatedImpactPoint:Vector2
var bCalculatedImpact:bool

# Simulation sanity limits
@export var maxSimulationDays:int = 10
# should also do a max distance from the screen centre, etc.

# Don't think I can pass by ref. Extending scope for step variables here for access across class:
var stepPos:Vector2
var stepVel:Vector2

var bInit:bool = false

# Runtime gameplay
var currentPositionIdx:int = 0
@export var orbitDebugViewType:EOrbitDebugViewType = EOrbitDebugViewType.SHOW_ALL

func is_final_day_before_impact():
	if !bCalculatedImpact:
		return false
	
	if currentPositionIdx < len(calculatedDayPositions):
		return false
		
	return true
	
	
const shield_angle_range:float = 0.2

func am_hitting_shield():
	var planet_to_shield_impact:Vector2 = calculatedImpactPoint - gravityCentrePos
	var asteroid_impact_angle:float = atan2(planet_to_shield_impact.y, planet_to_shield_impact.x) 
	var planet_to_shield_pos:Vector2 = GameState.shield_position - gravityCentrePos
	var shield_angle:float = atan2(planet_to_shield_pos.y, planet_to_shield_pos.x) 
	var angle_diff:float = abs(asteroid_impact_angle-shield_angle)
	if angle_diff > PI:
		# gone the long way round - go the other way!
		angle_diff = 2 * PI - angle_diff
	if angle_diff < shield_angle_range:
		return true
	return false	

func _ready() -> void:
	init()

func launch(launchVelocity:Vector2) -> void:
	init()
	update_simulation(launchVelocity)
	update_simulation_visual()

func init() -> void:
	if bInit:
		return
	
	stepPos = position
	stepVel = Vector2.ZERO
	print_tree()
	print_debug(get_parent())

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
	
	bInit = true
	
func _process(delta: float) -> void:
	pass

func _input(event):
	if Input.is_key_pressed(KEY_T):
		increment_day()
		update_simulation_visual()

func increment_day() -> void:
	currentPositionIdx = currentPositionIdx + 1
	
	if is_final_day_before_impact():
		var hit_shield = am_hitting_shield()
		print_debug(hit_shield)
	
func get_current_position() -> Vector2:
	if currentPositionIdx < len(spawnedGhostNodes):
		return spawnedGhostNodes[currentPositionIdx].global_position
	if bCalculatedImpact:
		return calculatedImpactPoint
	return Vector2.ZERO

func update_simulation(launchVelocity:Vector2) -> void:
	# here so that we can easily move things in debug mode
	gravityCentreLocalPos = to_local(gravityCentrePos)
	collisionDistanceSqr = (earthRadius + meteoroidRadius)*(earthRadius + meteoroidRadius);
	
	# Reset simulation
	calculatedDayPositions.clear()
	calculatedLineVertices.clear()
	bCalculatedImpact = false

	stepPos = Vector2.ZERO
	stepVel = launchVelocity

	var simulationTimeStep:float = dayTimeStep / simulationStepsPerDay;
	
	calculatedLineVertices.append(Vector2.ZERO)
	calculatedLineVertices.append(stepPos)
	# update this to a while loop with exit conditions
	for i in range(maxSimulationDays):
		var bCollidedThisDay:bool = false
		for step in range(simulationStepsPerDay):
			if !bCalculatedImpact:
				bCollidedThisDay = step_simulation(simulationTimeStep, step)
				if bCollidedThisDay:
					bCalculatedImpact = true
					calculatedLineVertices.append(calculatedImpactPoint)
				else:
					calculatedLineVertices.append(stepPos)
		if !bCalculatedImpact:
			calculatedDayPositions.append(stepPos)
	
func update_simulation_visual() -> void:
	# Draw path projection
	if orbitDebugViewType == EOrbitDebugViewType.SHOW_ALL || orbitDebugViewType == EOrbitDebugViewType.SHOW_CURRENT_AND_ARC:
		launchSimulationLineNode.points = calculatedLineVertices
	else:
		launchSimulationLineNode.points.clear()
		launchSimulationLineNode.visible = false
	
	# Draw positions for each day
	for iGhost in len(spawnedGhostNodes):
		var bGhostExists:bool = iGhost < len(calculatedDayPositions)
		var bToggledShowGhost:bool = (orbitDebugViewType != EOrbitDebugViewType.HIDE && iGhost == currentPositionIdx) || orbitDebugViewType == EOrbitDebugViewType.SHOW_ALL
		if bGhostExists && bToggledShowGhost:
			spawnedGhostNodes[iGhost].position = calculatedDayPositions[iGhost]
			spawnedGhostNodes[iGhost].visible = true
		else:
			spawnedGhostNodes[iGhost].visible = false

	impactSpriteNode.visible = bCalculatedImpact && orbitDebugViewType != EOrbitDebugViewType.HIDE
	if bCalculatedImpact:
		impactSpriteNode.position = calculatedImpactPoint
		
	launchDebugSpriteNode.visible = orbitDebugViewType == EOrbitDebugViewType.SHOW_ALL

# Returns true if impact
func step_simulation(timeStep: float, stepI: int) -> bool:
	#nice to have: if the distance is > some delta, step towards it in multiple stages
	
	var toGravityCentre:Vector2 = gravityCentreLocalPos - stepPos
	var toGravityCentreDistSqr = toGravityCentre.length_squared()
	
	if toGravityCentreDistSqr < collisionDistanceSqr:
		return true
	
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
	
	var nextStepVel:Vector2 = stepVel + externalForcesAccumulated * timeStep
	var nextStepPos:Vector2 = stepPos + stepVel * timeStep
	
	# Check for a new collision
	toGravityCentre = gravityCentreLocalPos - nextStepPos
	toGravityCentreDistSqr = toGravityCentre.length_squared()
	
	var bCollided:bool = false
	
	if toGravityCentreDistSqr <= collisionDistanceSqr:
		#print_debug(stepI)
		bCollided = true
		# There was a collision. Find the exact point:
		calculatedImpactPoint = interpolate_intersection_ray_sphere(stepPos, nextStepPos, gravityCentreLocalPos, sqrt(collisionDistanceSqr))
	
	stepVel = nextStepVel
	stepPos = nextStepPos
	
	return bCollided

func interpolate_intersection_ray_sphere(p0:Vector2, p1:Vector2, c:Vector2, r:float) -> Vector2:
	var P0P1Norm:Vector2 = (p1 - p0).normalized()
	var P0CProj:float = (c - p0).dot(P0P1Norm)
	
	var distanceToRaySqr:float = (c - p0).length_squared() - P0CProj*P0CProj
	var distanceTravelledInsideCollisionSqr:float = r*r-distanceToRaySqr
	if distanceTravelledInsideCollisionSqr < 0.0:
		return p0
	
	var distanceTravelledToCollision:float = P0CProj - sqrt(distanceTravelledInsideCollisionSqr)
	#print_debug(distanceTravelledToCollision)
	return p0 + distanceTravelledToCollision * P0P1Norm
	
	
	
