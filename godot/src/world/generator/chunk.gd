class_name Chunk extends Node2D

var size: Vector2

@export var show_borders:= true

func _draw() -> void:
	if not Debug.debug_build or not show_borders:
		return
	
	draw_rect(Rect2(Vector2.ZERO, size), Color.RED, false, 2)
	draw_line(Vector2(size.x/2, 0), Vector2(size.x/2, size.y), Color.BEIGE, 2)
	draw_line(Vector2(0, size.y/2), Vector2(size.x, size.y/2), Color.BEIGE, 2)
