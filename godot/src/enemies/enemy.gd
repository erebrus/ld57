class_name Enemy extends CharacterBody2D

signal player_detected
signal player_on_target
signal player_lost

@export var damage:float=100
@export var accel:float=5.0
@export var cruise_speed:float=40
@export var max_speed:float=80
@export var health:float=100.0
@export var vision_range:float=500.0

var nav_enabled:=false
var current_speed:float=0
var home:Vector2
var target_position:Vector2:
	set(_pos):
		target_position = _pos
		nav_agent.target_position = target_position
var target:Player
var target_visible:=false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready var detection_area: Area2D = $DetectionArea
@onready var hurt_area: Area2D = $HurtAreaPivot/HurtArea
@onready var detection_rc: RayCast2D = $DetectionRC
@onready var detection_timer: Timer = $DetectionTimer

func _ready() -> void:
	var det_shape := CircleShape2D.new()
	det_shape.radius=vision_range
	$DetectionArea/CollisionShape2D.shape = det_shape
	detection_rc.target_position=Vector2(vision_range, 0)
	await get_tree().process_frame
	home=global_position
	target_position = home
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	target=body
	detection_rc.enabled=true
	_on_detection_timer_timeout()
	detection_timer.start()

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_lost.emit()
	detection_rc.enabled=false
	target=null

func _on_hurt_area_body_entered(body: Node2D) -> void:
	player_on_target.emit()
	
func _process(delta: float) -> void:
	if target:
		detection_rc.target_position=Vector2(vision_range,0).rotated(global_position.angle_to_point(target.global_position))

	if nav_enabled:
		var wp = nav_agent.get_next_path_position()
		if not nav_agent.is_navigation_finished():
			do_movement(wp,delta)
	elif target_position.distance_to(global_position)> 5.0:
			do_movement(target_position, delta)

func do_movement(wp:Vector2, delta:float)->void:
	var direction := (wp-global_position).normalized()
	var speed = velocity.length()
	velocity=direction*current_speed
	face(wp)		
	var collision = move_and_collide(velocity*delta)
	if collision:
		_on_collision()
	
func face(target_direction:Vector2 ):
	$Sprite2D.flip_h= target_position.x < global_position.x
	hurt_area.position.x=abs(hurt_area.position.x)*(-1 if $Sprite2D.flip_h else 1)

func has_arrived()->bool:
	if nav_enabled:
		return nav_agent.is_navigation_finished()
	else:
		return target_position.distance_to(global_position)< 5.0
			
func is_player_on_target():
	var ret:= hurt_area.get_overlapping_bodies().has(target)
	return ret
	
func hurt_player():
	target.hurt(damage)

func _on_collision():
	pass

func has_line_to_target()->bool:
	if not target:
		return false
	
	var collider = detection_rc.get_collider()
	return collider!=null and collider is Player

	
func _on_detection_timer_timeout() -> void:
	if target == null:
		detection_timer.stop()
		return
	var target_was_visible = target_visible
	target_visible = has_line_to_target()
	if target_was_visible and not target_visible:
		Logger.info ("%s lost player " % name)
		player_lost.emit()
	elif not target_was_visible and target_visible:
		Logger.info ("%s detected player " % name)
		player_detected.emit()
