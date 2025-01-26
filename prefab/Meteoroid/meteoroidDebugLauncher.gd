extends Node2D

@export var launchDirectionNode:Node2D
@export var meteoroid:Node2D
@export var bResimulateLaunch:bool = false

func _ready() -> void:
	simulateLaunch()

func _process(delta: float) -> void:
	if bResimulateLaunch:
		simulateLaunch()

func simulateLaunch() -> void:
	if meteoroid && launchDirectionNode:
		var launchDirection = -launchDirectionNode.position
		meteoroid.launch(launchDirection)
		
