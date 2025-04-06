class_name Enemy extends CharacterBody2D

signal player_detected
signal player_on_target
signal player_lost

@export var damage:float=100
@export var accel:float=5.0
@export var max_speed:float=80
@export var health:float=100.0




var home:Vector2
var target_position:Vector2
var target:Player

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@onready var detection_area: Area2D = $DetectionArea
@onready var hurt_area: Area2D = $HurtArea

func _ready() -> void:
	await get_tree().process_frame
	home=global_position
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	target=body
	player_detected.emit()


func _on_hurt_area_body_entered(body: Node2D) -> void:
	player_on_target.emit()
	

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_lost.emit()
	target=null

func is_player_on_target():
	return hurt_area.get_overlapping_bodies().has(target)

func hurt_player():
	target.hurt(100)
