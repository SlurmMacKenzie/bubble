extends Node2D
var imgui:bool = false

func _process(delta: float) -> void:
	if imgui:
		Debug.do_imgui()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("debug"):
		imgui = !imgui
