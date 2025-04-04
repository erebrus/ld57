class_name Player extends RigidBody2D

@export_category("thrust")
@export var base_thrust_timeout := .8
@export var thrust := 400.0
@export var back_thrust_factor := .2
@export var strafe_thrust_factor := .3
@export var full_thrust_bonus := 1.2
@export var thrust_charge_speed :=2.0
@export_category("other movement")
@export var rotation_speed :=2.5
@export var friction := .7
@export_category("energy")
@export var max_energy:=100.0
@export var energy_per_thrust:=1.0
@export var no_energy_factor:=.5

var can_thrust:=true
var thrust_factor := 0.0

@onready var energy:float = max_energy:
	set(_energy):
		energy = _energy
		if light:
			light.energy = energy/max_energy
		

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var light: PointLight2D = $PointLight2D


func _ready():
	animation_player.play("idle")

func has_energy():
	return energy > 0 
	
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
		Logger.trace("start charge %d" %  Time.get_ticks_msec())
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		do_thrust()
	
func do_thrust(rotation_delta:float = 0):
	Logger.trace("thrust %d" % Time.get_ticks_msec())
	if not has_energy():
		thrust_factor *= no_energy_factor
	var intensity:float = thrust * thrust_factor * (full_thrust_bonus if thrust_factor>=1.0 else 1)
	Logger.info("thrust intensity %.2f" % intensity)
	apply_impulse(Vector2.RIGHT.rotated(rotation+rotation_delta)*intensity,Vector2.ZERO)
	can_thrust=false
	$%ThrustState.color=Color("red")
	animation_player.play("thrust")
	energy = max(0, energy-energy_per_thrust*thrust_factor)
	$ThrustTimer.wait_time = base_thrust_timeout*thrust_factor
	thrust_factor=0
	$ThrustTimer.start()
	Logger.trace("thrust NOT available %d" % Time.get_ticks_msec())
	Logger.info("light %.2f/%.2f" % [energy, light.energy])


func _on_thrust_timer_timeout() -> void:
	can_thrust=true
	if not Input.is_action_pressed("move_forward"):
		animation_player.play("idle")
	Logger.trace("thrust available %d" % Time.get_ticks_msec())

	$%ThrustState.color=Color("white")


func consume(krill:Krill):
	energy = min(max_energy, energy+krill.energy)
	Logger.info("light %.2f/%.2f" % [energy, light.energy])
