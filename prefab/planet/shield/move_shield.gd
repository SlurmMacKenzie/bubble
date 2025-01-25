extends Node
var shield:Shield
var planet:Planet

const radius:float = 320.0
var angle:float = 0.0

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
	
	var planet_to_mouse = mouse_pos - planet_pos
	if planet_to_mouse.length() < 0.01:
		# vector too small, just point up
		angle = 0.0
	else:
		angle = atan2(planet_to_mouse.y, planet_to_mouse.x) 
		
	planet_to_mouse = planet_to_mouse.normalized()
	shield.rotation = angle + PI / 2
	shield.position = planet_to_mouse * Vector2(radius, radius) 
	
	
	
	
