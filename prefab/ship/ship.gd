extends CharacterBody2D
class_name Ship


func update_sprite(remaining_bubble: int, anim:bool = false):
	match remaining_bubble:
		7,8,9: %ShipSprite.texture = load("res://assets/art/ship_sprite/ship_001.png")
		4,5,6: %ShipSprite.texture = load("res://assets/art/ship_sprite/ship_002.png")
		1,2,3: %ShipSprite.texture = load("res://assets/art/ship_sprite/ship_003.png")
		0: %ShipSprite.texture = load("res://assets/art/ship_sprite/ship_004.png")
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(%ShipSprite, "scale", Vector2(0.3,0.3), 0.1)
	tween.tween_property(%ShipSprite, "scale", Vector2(0.242,0.242), 1.0)
