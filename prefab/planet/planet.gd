extends StaticBody2D
class_name Planet

const health_max:int = 100
var health:int = health_max

func _ready() -> void:
	position = get_viewport_rect().size / 2
	
	GameState.take_damage.connect(_take_damage)
	GameState.update_health_bar.emit.call_deferred(health)


func _take_damage(damage):
	health -= damage
	health = clamp(health, 0, health_max)
	
	GameState.update_health_bar.emit(health)
	
	if health <= 0:
		GameState.planet_death_were_all_doomed.emit()
	
