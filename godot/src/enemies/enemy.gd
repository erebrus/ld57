class_name Enemy extends CharacterBody2D

signal player_detected
signal player_on_target
signal player_lost

var home:Vector2
var target_position:Vector2
var target:Player

func _ready() -> void:
	await get_tree().process_frame
	home=global_position
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	player_detected.emit()


func _on_hurt_area_body_entered(body: Node2D) -> void:
	player_on_target.emit()
	target=body

func _on_detection_area_body_exited(body: Node2D) -> void:
	player_lost.emit()
	target=null
