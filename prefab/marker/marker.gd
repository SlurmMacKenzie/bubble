extends Node2D

var time = 0

func _ready() -> void:
	var id = randi_range(1,4)
	$Sprite2D.texture = load("res://assets/art/asteroids/asteroid_solid_0"+ str(id) +".png")
	
	
func set_time(value: int):
	time = value
	$RichTextLabel.text = str(time)

func increase_time():
	time += 1
	$RichTextLabel.text = str(time)
	var id = randi_range(1,4)
	$Sprite2D.texture = load("res://assets/art/asteroids/asteroid_marker_0"+ str(id) +".png")


func appear():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($Sprite2D, "scale", Vector2(0.5,0.5), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(0.32,0.32), 1.0)
