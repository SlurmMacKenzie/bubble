extends Node
var shield:Shield
var planet:Planet

const radius:float = 300.0

func _ready() -> void:
	shield = owner
	planet = get_parent().get_parent()
	shield.position = Vector2(0, -radius) 
	shield.rotation_degrees = 0.0

func _physics_process(delta: float) -> void:
	
	# rotate about centre of planet... erm.... hackety hacket hack, let's call it a proof of concept
	if(Input.get_action_strength("right")):
		shield.position = Vector2(radius, 0) 
		shield.rotation_degrees = 90.0
	else: if(Input.get_action_strength("left")):
		shield.position = Vector2(-radius, 0) 
		shield.rotation_degrees = 270.0
	else: if(Input.get_action_strength("thursters")):
		shield.position = Vector2(0, -radius) 
		shield.rotation_degrees = 0.0
	else: if(Input.get_action_strength("down")):
		shield.position = Vector2(0, radius) 
		shield.rotation_degrees = 180.0
	  
	
	
	
