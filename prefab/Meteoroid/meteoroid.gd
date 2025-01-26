extends Node2D

enum EOrbitPhysicsType {DIST_SQR,DIST,CONST} 
enum EOrbitDebugViewType {SHOW_ALL,SHOW_CURRENT_AND_ARC,SHOW_CURRENT,HIDE}

@export var launchSimulationLineNode:Node2D
@export var impactSpriteNodeEarth:Node2D
@export var impactSpriteNodeShield:Node2D
@export var launchDebugSpriteNode:Node2D

var ghostScene: PackedScene = load("res://prefab/Meteoroid/meteoroidGhost.tscn")
var spawnedGhostNodes:Array

@export var dayTimeStep:float = 1.0
@export var simulationStepsPerDay:float = 10.0 # how many steps to simulate within a day
@export var orbitPhysicsType:EOrbitPhysicsType = EOrbitPhysicsType.DIST_SQR
@export var drag:float = 0.003

# These are guesses for testing
@export var earthRadius:float = 85.0
@export var shieldRadius:float = 105.0
@export var meteoroidRadius:float = 0.0

@export var gravityStrengthMult:float = 100.0

var earthNode:Node2D
var gravityCentrePos:Vector2
var gravityCentreLocalPos:Vector2

# Results of calculations we need to run the game. In debugging, we can recalculate every frame
var calculatedDayPositions:PackedVector2Array
var calculatedLineVertices:PackedVector2Array
var calculatedImpactPointShield:Vector2
var calculatedImpactPointEarth:Vector2
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
var bShowTrajectory:bool = false # after 2 points are found, show the trajectory
var numTimesPinned:int = 0 # once this meteor has been pinned twice, show the trajectory

func is_final_day_before_impact():
	if !bCalculatedImpact:
		return false
	
	return (currentPositionIdx == len(calculatedDayPositions)-1)
	


func am_hitting_shield():
	var planet_to_shield_impact:Vector2 = to_global(calculatedImpactPointShield) - gravityCentrePos
	var asteroid_impact_angle:float = atan2(planet_to_shield_impact.y, planet_to_shield_impact.x) 
	var planet_to_shield_pos:Vector2 = GameState.shield_position - gravityCentrePos
	var shield_angle:float = atan2(planet_to_shield_pos.y, planet_to_shield_pos.x) 
	var angle_diff:float = abs(asteroid_impact_angle-shield_angle)
	if angle_diff > PI:
		# gone the long way round - go the other way!
		angle_diff = 2 * PI - angle_diff
	if angle_diff < GameState.shield_angle_extent:
		return true
	return false	

func _ready() -> void:
	init()
	GameState.day_incremented.connect(_onDayIncremented)

func launch(launchVelocity:Vector2) -> void:
	init()
	update_simulation(launchVelocity)
	update_simulation_visual()

func init() -> void:
	if bInit:
		return
	
	stepPos = position
	stepVel = Vector2.ZERO

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
	var bUpdatedView:bool = false
	if Input.is_key_pressed(KEY_KP_3):
		orbitDebugViewType = EOrbitDebugViewType.SHOW_ALL
		bUpdatedView = true
	if Input.is_key_pressed(KEY_KP_2):
		orbitDebugViewType = EOrbitDebugViewType.SHOW_CURRENT_AND_ARC
		bUpdatedView = true
	if Input.is_key_pressed(KEY_KP_1):
		orbitDebugViewType = EOrbitDebugViewType.SHOW_CURRENT
		bUpdatedView = true
	if Input.is_key_pressed(KEY_KP_0):
		orbitDebugViewType = EOrbitDebugViewType.HIDE
		bUpdatedView = true
	
	if bUpdatedView:
		update_simulation_visual()

func _input(event):
	if Input.is_key_pressed(KEY_T):
		increment_day()
		update_simulation_visual()

func pin():
	numTimesPinned = numTimesPinned + 1
	if numTimesPinned == 2:
		bShowTrajectory = true
		update_simulation_visual()

func increment_day() -> void:
	
	if is_final_day_before_impact():
		var hit_shield:bool = am_hitting_shield()
		if hit_shield:
			print_debug("SHIELDED")
		else:
			print_debug("HIT")
			GameState.take_damage.emit(10)
		GameState.meteoroid_destroyed.emit()
		
	currentPositionIdx = currentPositionIdx + 1

func get_current_position() -> Vector2:
	if currentPositionIdx < len(spawnedGhostNodes):
		return spawnedGhostNodes[currentPositionIdx].global_position
	if bCalculatedImpact:
		return calculatedImpactPointEarth
	return Vector2.ZERO

func update_simulation(launchVelocity:Vector2) -> void:
	# here so that we can easily move things in debug mode
	gravityCentreLocalPos = to_local(gravityCentrePos)
	
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
	var distToEarthCentreSqr:float = INF
	for i in range(maxSimulationDays):
		for step in range(simulationStepsPerDay):
			if !bCalculatedImpact:
				distToEarthCentreSqr = step_simulation(simulationTimeStep, step)
				if distToEarthCentreSqr < earthRadius*earthRadius:
					bCalculatedImpact = true
					calculatedLineVertices.append(calculatedImpactPointEarth) # always finish the line at the end
				else:
					calculatedLineVertices.append(stepPos)
		if !bCalculatedImpact && distToEarthCentreSqr > shieldRadius*shieldRadius: # don't add any day positions past the shield
			calculatedDayPositions.append(stepPos)
	
func update_simulation_visual() -> void:
	# Draw path projection
	if bShowTrajectory || orbitDebugViewType == EOrbitDebugViewType.SHOW_ALL || orbitDebugViewType == EOrbitDebugViewType.SHOW_CURRENT_AND_ARC:
		launchSimulationLineNode.points = calculatedLineVertices
		launchSimulationLineNode.visible = true
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

	var bImpactSpritesVisible = bCalculatedImpact && orbitDebugViewType != EOrbitDebugViewType.HIDE
	impactSpriteNodeEarth.visible = bImpactSpritesVisible
	impactSpriteNodeShield.visible = bImpactSpritesVisible
	if bCalculatedImpact:
		impactSpriteNodeEarth.position = calculatedImpactPointEarth
		impactSpriteNodeShield.position = calculatedImpactPointShield
		
	launchDebugSpriteNode.visible = orbitDebugViewType == EOrbitDebugViewType.SHOW_ALL

# Returns distance to earth centre sqr
func step_simulation(timeStep: float, stepI: int) -> float:
	#nice to have: if the distance is > some delta, step towards it in multiple stages
	
	var toGravityCentre:Vector2 = gravityCentreLocalPos - stepPos
	var toGravityCentreDistSqr = toGravityCentre.length_squared()
	
	if toGravityCentreDistSqr < earthRadius*earthRadius:
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
	var nextToGravityCentre = gravityCentreLocalPos - nextStepPos
	var nextTooGravityCentreDistSqr = nextToGravityCentre.length_squared()
		
	if nextTooGravityCentreDistSqr <= shieldRadius*shieldRadius && toGravityCentreDistSqr > shieldRadius*shieldRadius:
		#print_debug(stepI)
		# We've gone past the shield. Find the impact points:
		calculatedImpactPointShield = interpolate_intersection_ray_sphere(stepPos, nextStepPos, gravityCentreLocalPos, shieldRadius)
	
	# note: we only hit this once, since afterwards we will early exit the fn
	if nextTooGravityCentreDistSqr <= earthRadius*earthRadius:
		#print_debug(stepI)
		# We've hit the planet. Find the impact points:
		calculatedImpactPointEarth = interpolate_intersection_ray_sphere(stepPos, nextStepPos, gravityCentreLocalPos, earthRadius)
	
	stepVel = nextStepVel
	stepPos = nextStepPos
	
	return nextTooGravityCentreDistSqr

func interpolate_intersection_ray_sphere(p0:Vector2, p1:Vector2, c:Vector2, r:float) -> Vector2:
	var P0P1Norm:Vector2 = (p1 - p0).normalized()
	var P0CProj:float = (c - p0).dot(P0P1Norm)
	
	var distanceToRaySqr:float = (c - p0).length_squared() - P0CProj*P0CProj
	var distanceTravelledInsideCollisionSqr:float = r*r-distanceToRaySqr
	if distanceTravelledInsideCollisionSqr < 0.0:
		return p0
	
	var distanceTravelledToCollision:float = P0CProj - sqrt(distanceTravelledInsideCollisionSqr)
	return p0 + distanceTravelledToCollision * P0P1Norm

func _onDayIncremented():
	increment_day()
	update_simulation_visual()
	
	
