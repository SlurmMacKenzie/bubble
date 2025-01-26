extends Node

signal bubble_pop(bubble: Bubble, dots: bool)
signal bubble_spawn(remaining: int)

var bubbles = []
var markers = []
var collisions = {}

const bubble_limit:int = 9
var bubble_count:int = bubble_limit

var day:int = 1

func _ready() -> void:
	connect("bubble_pop", on_bubble_pop)
	GameState.connect("game_state_changed", on_gamestate_changed)

func on_bubble_pop(bubble: Bubble, dots: bool):
	if dots:
		bubbles.append({
			"bubble": bubble,
			"day": day
		})
		if !collisions.has(bubble.pop_pos):
			collisions[bubble.pop_pos] = 1
		else:
			collisions[bubble.pop_pos] = collisions[bubble.pop_pos] + 1
		
		if collisions[bubble.pop_pos] == 3:
			var meteoroid = MeteoroidLauncher.getClosestMeteorPos(bubble.pop_pos)
			var meteoroidPos = meteoroid.get_current_position()
			
			spawn_marker(bubble.pop_pos, meteoroidPos)
			meteoroid.pin()
			
			var to_erase = []
			var to_delete = []
			for b in bubbles:
				if b["day"] == day and b["bubble"].pop_pos == bubble.pop_pos:
					to_delete.append(b["bubble"])
					to_erase.append(b)
			for k in to_erase:
				bubbles.erase(k)
			for b in to_delete:
				b.delete()


func spawn_marker(pos: Vector2, meteoroid):
	var m = load("res://prefab/marker/marker.tscn")
	var marker_instance = m.instantiate()
	add_child(marker_instance)
	marker_instance.global_position = pos
	marker_instance.appear()
	markers.append({
		"marker": marker_instance,
		"day": day,
		"meteoroid": meteoroid
	})
	
func check_intersection(b1: Bubble, b2: Bubble):
	return intersectTwoCircles(b1.global_position, b1.radius, b2.global_position, b2.radius)

func intersectTwoCircles(pos1: Vector2,r1, pos2: Vector2 ,r2):
	var dist = pos1.distance_to(pos2)
	if !((abs(r1 - r2) <= dist) and dist <= r1 + r2):
		return []
	
	var R2 = dist*dist
	var R4 = R2*R2
	var a = (r1*r1 - r2*r2) / (2 * R2)
	var r2r2 = (r1*r1 - r2*r2)
	var c = sqrt(2 * (r1*r1 + r2*r2) / R2 - (r2r2 * r2r2) / R4 - 1)

	var fx = (pos1.x+pos2.x) / 2 + a * (pos2.x - pos1.x)
	var gx = c * (pos2.y - pos1.y) / 2
	var ix1 = fx + gx;
	var ix2 = fx - gx;

	var fy = (pos1.y+pos2.y) / 2 + a * (pos2.y - pos1.y)
	var gy = c * (pos1.x - pos2.x) / 2
	var iy1 = fy + gy;
	var iy2 = fy - gy;

	return [[ix1, iy1], [ix2, iy2]]

func on_gamestate_changed():
	collisions.clear()
	if(GameState.current_state == GameState.GAME_STATE.ASTEROID):
		day += 1
		for m in markers:
			m["marker"].increase_time()
	
		for b in bubbles:
			b["bubble"].increase_time()
