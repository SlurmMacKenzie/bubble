@tool
extends Polygon2D
class_name Bubble

@export var radius:float = 10.0
@export var noise1:FastNoiseLite

const grow_ratio:float = 20.0
const sample_size:int = 64
const wobble_speed:float = 0.2
const wobble_weight:float = 1

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() and Input.is_action_pressed("grow_bubble"):
		radius += delta * grow_ratio
	draw_bubble()


func draw_bubble():
	var pos_list: PackedVector2Array = PackedVector2Array()
	var step = (2 * PI) / sample_size
	for point in range(sample_size):
		var radian = step * point
		var radian_pos = Vector2(cos(radian), sin(radian)) * get_height(radian)
		pos_list.append(radian_pos)
	
	polygon = pos_list

func get_height(radian: float) -> float:
	return radius + sqrt(radius) * wobble_weight *  noise1.get_noise_2d(cos(radian) * Time.get_ticks_msec() * wobble_speed, sin(radian) * Time.get_ticks_msec() * wobble_speed)
