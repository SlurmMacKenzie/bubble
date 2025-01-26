extends Control

@onready var timerVariable = $Timer
@onready var cutsceneOrder = $"Cutscene order"


@onready var scenes = [$"Cutscene order/Scene 1",$"Cutscene order/Scene 2"]
var scene_count = 2
var scene_i = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	print_debug(scene_i)
	print_debug(scene_count)
	if(scene_i == scene_count-1):
		scenes[scene_i].hide()
		scenes[scene_i].show()
		timerVariable.stop()
	else:
		scenes[scene_i].hide()
		scene_i += 1
		scenes[scene_i].show()
