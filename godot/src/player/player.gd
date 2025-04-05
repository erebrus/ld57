class_name Player extends RigidBody2D

@export var base_thrust_timeout := .8
@export var thrust := 400.0
@export var back_thrust_factor := .2
@export var strafe_thrust_factor := .3
@export var torque:= 10.0
@export var thrust_charge_speed :=2.0
@export var rotation_speed :=2.5
@export var friction := .7

var can_thrust:=true
var thrust_factor := 0.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	animation_player.play("idle")
	
func _physics_process(delta: float) -> void:
	var rotate_input:float = Input.get_axis("rotate_left","rotate_right")
	if rotate_input:
		rotation += rotate_input * rotation_speed * delta
		#apply_torque(rotate_input*torque)#*delta)

	if can_thrust:
		if Input.is_action_pressed("move_forward"):
			charge_thrust(delta)
		elif Input.is_action_just_released("move_forward"):
			do_thrust()
		if Input.is_action_just_pressed("move_back"):
			thrust_factor = back_thrust_factor
			do_thrust(PI)
		elif Input.is_action_just_pressed("move_left"):
			thrust_factor=strafe_thrust_factor
			do_thrust(-PI/2)
		elif Input.is_action_just_pressed("move_right"):
			thrust_factor=strafe_thrust_factor
			do_thrust(PI/2)
	
func charge_thrust(delta:float):
	if thrust_factor == 0:
		thrust_factor = .2	
		animation_player.play("charge")
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		do_thrust()
	
func do_thrust(rotation_delta:float = 0):

	apply_impulse(Vector2.RIGHT.rotated(rotation+rotation_delta)*thrust*thrust_factor,Vector2.ZERO)
	can_thrust=false
	$%ThrustState.color=Color("red")
	animation_player.play("thrust")

	$ThrustTimer.wait_time = base_thrust_timeout*thrust_factor
	thrust_factor=0
	$ThrustTimer.start()


func _on_thrust_timer_timeout() -> void:
	can_thrust=true
	if not Input.is_action_pressed("move_forward"):
		animation_player.play("idle")

	$%ThrustState.color=Color("white")
