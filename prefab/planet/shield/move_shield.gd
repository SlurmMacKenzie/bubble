extends Node
var shield:Shield
var planet:Planet

const radius:float = 350.0
const rotatey_speed_per_frame:float = 1.0


func _ready() -> void:
	shield = owner
	planet = get_parent().get_parent()
	shield.position = Vector2(0, -radius) 
	shield.rotation_degrees = 0.0

func _physics_process(delta: float) -> void:
	
	# rotate about centre of planet... 
	# what direction is the mouse pointer from the planet?
	var mouse_pos = get_viewport().get_mouse_position()
	var planet_pos = planet.global_position
	var shield_pos = shield.global_position
	var planet_to_mouse = mouse_pos - planet_pos
	var planet_to_shield = shield_pos - planet_pos
	var current_shield_angle = atan2(planet_to_shield.y, planet_to_shield.x) 
	var desired_shield_angle = 0.0
	if planet_to_mouse.length() > 0.01:
		desired_shield_angle = atan2(planet_to_mouse.y, planet_to_mouse.x) 
		
	var new_angle = 0
	# move towards desired_angle
	var max_angle_diff = rotatey_speed_per_frame * delta
	if(absf(current_shield_angle-desired_shield_angle)) < max_angle_diff:
		# go straight there
		new_angle = desired_shield_angle
	else: 
		var cross = planet_to_shield.cross(planet_to_mouse)
		if cross > 0:
			new_angle = current_shield_angle + max_angle_diff 
		else:
			new_angle = current_shield_angle - max_angle_diff 
	
	var new_planet_to_shield = Vector2(radius, 0).rotated(new_angle)
	shield.rotation = new_angle + PI /2
	shield.position = new_planet_to_shield
	
	GameState.shield_position = shield.global_position

	
