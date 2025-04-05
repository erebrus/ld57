@tool
class_name Current extends Area2D

@export var size:Vector2 = Vector2 (1000,1000):
	set(_size):
		size=_size
		refresh_shape()
@export var direction:Vector2 = Vector2.DOWN
@export var intensity:float = 10

func _ready() -> void:
	$CollisionShape2D.shape=RectangleShape2D.new()
	refresh_shape()
	
func refresh_shape():
	if $CollisionShape2D.shape:
		($CollisionShape2D.shape as RectangleShape2D).size=size

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var list = get_overlapping_bodies()
	for body in list:
		if body is RigidBody2D:
			body.apply_force(direction*intensity*body.mass)
