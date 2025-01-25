extends RigidBody2D
class_name Bubble

@export var radius:float = 5.0
@export var max_radius:float = 128.0
@export var noise1:FastNoiseLite

var tween_fadeout:Tween
var osc_force:float = 0.0

var detached = false
const grow_ratio:float = 20.0
const sample_size:int = 32
const wobble_speed:float = 0.2
const wobble_weight:float = 0.3

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() and Input.is_action_pressed("grow_bubble") and !detached:
		radius += delta * grow_ratio
	draw_bubble()
	
	if radius > max_radius and freeze:
		freeze = false
		detached = true
		tween_fadeout = create_tween()
		tween_fadeout.tween_property(self, "modulate:a", 0.0, 1.5).connect("finished", on_fadeout_end)

func on_fadeout_end():
	self.get_parent().remove_child(self)
	self.queue_free()
	
func draw_bubble():
	var pos_list: PackedVector2Array = PackedVector2Array()
	var step = (2 * PI) / sample_size
	for point in range(sample_size):
		var radian = step * point
		var radian_pos = Vector2(cos(radian), sin(radian)) * get_height(radian)
		pos_list.append(radian_pos)
	
	%BubbleVisual.polygon = pos_list
	%CollisionShape2D.shape.radius = radius
	pos_list.append(pos_list[0])
	%Line2D.points = pos_list
	%BubbleVisual.texture_scale = Vector2(radius,radius)
	%BubbleVisual.scale = Vector2(1 + sin(Time.get_ticks_msec() * 0.01) * osc_force, 1 + cos(Time.get_ticks_msec() * 0.01) * osc_force)
	osc_force = lerpf(osc_force, 0, 0.1)
	%Line2D.scale = Vector2(1 + sin(Time.get_ticks_msec() * 0.01) * osc_force, 1 + cos(Time.get_ticks_msec() * 0.01) * osc_force)

func update_position(pos: Vector2):
		if !detached:
			position = pos

func get_height(radian: float) -> float:
	return radius  + sqrt(radius) * wobble_weight *  noise1.get_noise_2d(cos(radian) * (Time.get_ticks_msec() + 5) * wobble_speed, sin(radian) * Time.get_ticks_msec() * wobble_speed)
