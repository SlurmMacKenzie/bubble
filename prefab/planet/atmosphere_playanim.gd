extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.current_animation = "ArmatureAction_001"
	$AnimationPlayer.play()
	
	var planet = get_parent().get_parent()
	if planet is Planet:
		var the_planet:Planet = planet
		the_planet.update_health_bar.connect(_update_health_bar)

const MIN_HEALTH_SCALE:float = 0.86
const MAX_HEALTH_SCALE:float = 1.3
func _update_health_bar(health:float):
	# health 0 => MIN_HEALTH_SCALE, health 100 =>MAX_HEALTH_SCALE
	var new_scale = health/100.0 * (MAX_HEALTH_SCALE-MIN_HEALTH_SCALE) + MIN_HEALTH_SCALE
	scale = Vector3(new_scale,new_scale,new_scale)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
