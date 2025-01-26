extends Control

@onready var scenes = [$"Cutscene order/Scene 0",$"Cutscene order/Scene 1",$"Cutscene order/Scene 2",$"Cutscene order/Scene 3",$"Cutscene order/Scene 4",$"Cutscene order/Scene 5"]
var scene_count = 6
var scene_i = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if(scene_i == scene_count-1):
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	else:
		scenes[scene_i].hide()
		scene_i += 1
		scenes[scene_i].show()
	
	if(scene_i == scene_count-1):
		$Button.text = "Play!"
