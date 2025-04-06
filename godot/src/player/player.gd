class_name Player extends RigidBody2D

@export_category("thrust")
@export var base_thrust_timeout := .8
@export var thrust := 400.0
@export var back_thrust_factor := .2
@export var strafe_thrust_factor := .25
@export var full_thrust_bonus := 1.2
@export var thrust_charge_speed :=2.0
@export var min_thrust_timeout := .4
@export_category("other movement")
@export var rotation_speed :=2.5
@export var friction := .7
@export_category("energy")
@export var max_energy:=100.0
@export var energy_per_thrust:=10.0
@export var no_energy_factor:=.5

@export_category("noise")
@export var noise_range:float = 600.0
@export var thrust_noise_curve:Curve

var can_thrust:=true
var thrust_factor := 0.0
var last_thrust_direction:=Vector2.RIGHT

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
			last_thrust_direction = Vector2.RIGHT
			do_thrust()
		if Input.is_action_just_pressed("move_back"):
			last_thrust_direction = Vector2.LEFT
			thrust_factor = back_thrust_factor
			do_thrust(PI)
		elif Input.is_action_just_pressed("move_left"):
			last_thrust_direction = Vector2.UP
			thrust_factor=strafe_thrust_factor
			do_thrust(-PI/2)
		elif Input.is_action_just_pressed("move_right"):
			last_thrust_direction = Vector2.DOWN
			thrust_factor=strafe_thrust_factor
			do_thrust(PI/2)
	
func charge_thrust(delta:float):
	if thrust_factor == 0:
		thrust_factor = .2	
		animation_player.play("charge")
		Logger.debug("start charge %d" %  Time.get_ticks_msec())
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		last_thrust_direction = Vector2.RIGHT
		do_thrust()
	
func do_thrust(rotation_delta:float = 0):
	var thrust_direction=Vector2.RIGHT.rotated(rotation+rotation_delta)
	Logger.debug("thrust %d" % Time.get_ticks_msec())
	if not has_energy():
		thrust_factor *= no_energy_factor
	var intensity:float = thrust * thrust_factor * (full_thrust_bonus if thrust_factor>=1.0 else 1)
	Logger.debug("thrust intensity %.2f" % intensity)
	apply_impulse(thrust_direction * intensity,Vector2.ZERO)
	do_noise()
	can_thrust=false
	$%ThrustState.color=Color("red")
	match last_thrust_direction:
		Vector2.LEFT:
			Logger.debug("thrust back")
			animation_player.play("back")
		Vector2.UP:
			Logger.debug("strafe left")
			animation_player.play("strafe_left")
		Vector2.DOWN:
			Logger.debug("strafe right")
			animation_player.play("strafe_right")
		_:
			Logger.debug("thrust forward")
			animation_player.play("thrust")

			
	$ThrustTimer.wait_time = max(min_thrust_timeout, base_thrust_timeout*thrust_factor *( 1 if has_energy() else 1.15))
	Logger.debug("wait time %.2f" % $ThrustTimer.wait_time )
	energy = max(0, energy-energy_per_thrust*thrust_factor)

	thrust_factor=0
	$ThrustTimer.start()
	Logger.debug("thrust NOT available %d" % Time.get_ticks_msec())
	Logger.debug("light %.2f/%.2f" % [energy, light.energy])

func do_noise():
	Events.player_noise_ping.emit(global_position, noise_range*thrust_factor)
	
func _on_thrust_timer_timeout() -> void:
	can_thrust=true
	$%ThrustState.color=Color("white")
	Logger.debug("thrust available %d" % Time.get_ticks_msec())
	match last_thrust_direction:
		Vector2.LEFT:
			animation_player.play("idle")
		_:#Vector2.RIGHT:
			if not Input.is_action_pressed("move_forward"):
				animation_player.play("thrust_to_idle")
				await animation_player.animation_finished
				animation_player.play("idle")
		

	


func consume(krill:Krill):
	energy = min(max_energy, energy+krill.energy)
	Logger.debug("light %.2f/%.2f" % [energy, light.energy])

func hurt(dmg:float):
	Logger.info("hurt")
	visible=false
	await get_tree().create_timer(1).timeout
	get_tree().quit()
