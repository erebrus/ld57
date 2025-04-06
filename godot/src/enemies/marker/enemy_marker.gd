@tool 
extends Marker2D

@export var enemy_type: Types.EnemyType

@export var flip_h: bool:
	set(value):
		flip_h = value
		queue_redraw()


func _draw():
	if Engine.is_editor_hint():
		var direction = 1
		if flip_h:
			direction = -1
		
		var array: Array[Vector2]
		array.append(Vector2(20 * direction, 5))
		array.append(Vector2(20 * direction, -5))
		array.append(Vector2(30 * direction, 0))
		
		draw_colored_polygon(PackedVector2Array(array), Color.RED)
