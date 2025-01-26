extends StaticBody2D
class_name Planet

signal take_damage(damage)

signal planet_death_were_all_doomed()

const health_max:int = 100
var health:int = health_max

func _ready() -> void:
	position = get_viewport_rect().size / 2
	
	take_damage.connect(_take_damage)
	var health_bar = get_node("HealthBar")
	health_bar.update_health_bar.emit(health)


func _take_damage(damage):
	health -= damage
	health = clamp(health, 0, health_max)
	
	var health_bar = get_node("HealthBar")
	health_bar.update_health_bar.emit(health)
	
	if health <= 0:
		planet_death_were_all_doomed.emit()
	
