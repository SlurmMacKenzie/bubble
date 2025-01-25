extends Area2D
class_name Bubble

@export var radius:float = 5.0
@export var max_radius:float = 128.0
@export var noise1:FastNoiseLite

var tween_fadeout:Tween
var osc_force:float = 0.0

var bubble_count:int = 3

var detached = false
var poped = false
var ship_in_bubble = false

var ship:Ship = null
var ship_angle = 0.0
var ship_entrance_amplitude = 0.0

const grow_ratio:float = 20.0
const sample_size:int = 64
const wobble_speed:float = 0.2
const wobble_weight:float = 0.3

func _physics_process(delta: float) -> void:
	radius += delta * grow_ratio
	draw_bubble()
	
		pop(true)

func on_fadeout_end():
	pass
	#self.get_parent().remove_child(self)
	#self.queue_free()
	
func draw_bubble():
	if poped:
		return
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
	%Dots.points = pos_list
	%BubbleVisual.texture_scale = Vector2(radius,radius)
	%BubbleVisual.scale = Vector2(1 + sin(Time.get_ticks_msec() * 0.5) * osc_force, 1 + cos(Time.get_ticks_msec() * 0.01) * osc_force)
	osc_force = lerpf(osc_force, 0, 0.1)
	%Line2D.scale = Vector2(1 + sin(Time.get_ticks_msec() * 0.01) * osc_force, 1 + cos(Time.get_ticks_msec() * 0.01) * osc_force)

func update_position(pos: Vector2):
		if !detached:
			position = pos
			detached = true

func get_height(radian: float) -> float:
	var offset = 1.0
	if radian >= ship_angle - 0.6 and radian <= ship_angle + 0.6:
		offset = 1 + sin(Time.get_ticks_msec() * 0.01)  * ship_entrance_amplitude * (1-abs(radian - ship_angle)*0.6)
	if ship_entrance_amplitude > 0:
		ship_entrance_amplitude = clampf(ship_entrance_amplitude - get_process_delta_time() * 0.4, 0, 15)
	else:
		offset = 1.0
	
	return radius  + sqrt(radius) * wobble_weight * offset * noise1.get_noise_2d(cos(radian) * (Time.get_ticks_msec() + 5) * wobble_speed, sin(radian) * Time.get_ticks_msec() * wobble_speed)

func pop(show_dots: bool):
	detached = true
	poped = true
	%CPUParticles2D.emission_sphere_radius = radius
	%CPUParticles2D.emitting = true
	%BubbleVisual.visible = false
	%Line2D.visible = false
	%Dots.visible = show_dots
	%CollisionShape2D.set_deferred("disabled", true)
	%Pop.play()
	#tween_fadeout = create_tween()
	#tween_fadeout.tween_property(self, "modulate:a", 0.0, 0.03).connect("finished", on_fadeout_end)


func _on_body_entered(body: Node2D) -> void:
	if body is Ship:
		ship = body
		var v:Vector2 = position.direction_to(ship.position)
		ship_angle = v.angle()
		ship_entrance_amplitude = 10
		print("ship_entered")
		


func _on_body_exited(body: Node2D) -> void:
	if body is Ship:
		ship = body
		var v:Vector2 = position.direction_to(ship.position)
		ship_angle = v.angle()
		ship_entrance_amplitude = 10
		print("ship_exit")
