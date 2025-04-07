extends Control

func _ready() -> void:
	Events.indicador_requested.connect(display_at_angle)
	$AnimatedSprite2D.play("default")
func display_at_angle(angle:float, dist:float):
	var screen_size = get_viewport_rect().size
	var screen_center = screen_size / 2
	
	var padding = 24.0
	var max_radius = min (screen_size.x, screen_size.y) /2.0 - padding
	
	var direction = Vector2.RIGHT.rotated(angle)
	#var position_on_screen = screen_center + direction * max_radius
	var far_point = screen_center + direction * 2000
	var position_on_screen = get_position_on_edge(screen_center, far_point, screen_size, padding)	

	
	global_position = position_on_screen
	visible = true
	await get_tree().create_timer(.5).timeout
	visible = false
	
func get_position_on_edge(center: Vector2, point: Vector2, screen_size: Vector2, padding: float) -> Vector2:
	var bounds = Rect2(Vector2(padding, padding), screen_size - Vector2(padding * 2, padding * 2))
	var dir = (point - center).normalized()

	var t_values = []

	if dir.x != 0.0:
		var tx1 = (bounds.position.x - center.x) / dir.x
		var tx2 = (bounds.position.x + bounds.size.x - center.x) / dir.x
		t_values.append(tx1)
		t_values.append(tx2)

	if dir.y != 0.0:
		var ty1 = (bounds.position.y - center.y) / dir.y
		var ty2 = (bounds.position.y + bounds.size.y - center.y) / dir.y
		t_values.append(ty1)
		t_values.append(ty2)

	# Find the smallest positive t to reach the edge
	var t_min = INF
	for t in t_values:
		if t > 0:
			t_min = min(t_min, t)

	return center + dir * t_min
