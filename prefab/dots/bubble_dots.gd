extends Line2D


func increase_time() -> bool:
	modulate -= Color(0.34,0.34,0.34,0.34)
	return modulate.a <= 0
