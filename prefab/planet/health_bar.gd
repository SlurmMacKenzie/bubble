extends ProgressBar

signal update_health_bar(health)

func _ready() -> void:
	update_health_bar.connect(_update_health_bar)

func _update_health_bar(health: int) -> void:
	value = health
