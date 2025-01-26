extends ProgressBar

func _ready() -> void:
	var planet: Planet = get_parent()
	planet.update_health_bar.connect(_update_health_bar)

func _update_health_bar(health: int) -> void:
	value = health
