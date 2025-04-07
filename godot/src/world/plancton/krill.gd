class_name Krill extends RigidBody2D

const INNER_ROTATION_SPEED = 2 * PI / 6
const OUTER_ROTATION_SPEED = 2 * PI / 15

@export var base_energy:= 20.0
@export var energy_variance:=5.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var floaty_bits_container: Node2D = %FloatyBits
@onready var floaty_bits: Array = floaty_bits_container.get_children()

var energy:float
func _ready():
	energy = base_energy-energy_variance+2*energy_variance*randf()
	var intensity = $Polygon2D.material.get("shader_parameter/intensity")
	#$Polygon2D.material.set("shader_parameter/intensity", intensity*energy/base_energy)

func _physics_process(delta):
	floaty_bits_container.rotation += OUTER_ROTATION_SPEED * delta
	for node in floaty_bits:
		node.rotation += INNER_ROTATION_SPEED * delta
	

func _on_player_detection_area_body_entered(body: Node2D) -> void:
	Logger.info("krill detecting %s" % body)
	if body is Player:
		body.consume(self)
		fade()
		
func fade():
	animation_player.play("fade")
	await animation_player.animation_finished
	queue_free()
