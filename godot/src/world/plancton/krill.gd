class_name Krill extends RigidBody2D

@export var base_energy:= 20.0
@export var energy_variance:=5.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var energy:float
func _ready():
	energy = base_energy-energy_variance+2*energy_variance*randf()
	var intensity = $Polygon2D.material.get("shader_parameter/intensity")
	#$Polygon2D.material.set("shader_parameter/intensity", intensity*energy/base_energy)

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	Logger.info("krill detecting %s" % body)
	if body is Player:
		body.consume(self)
		fade()
		
func fade():
	animation_player.play("fade")
	await animation_player.animation_finished
	queue_free()
