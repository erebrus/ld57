class_name Player extends RigidBody2D

@export var base_thrust_timeout:=.8
@export var thrust:= 400.0
@export var torque:= 10.0
@export var thrust_charge_speed :=2.0
const FRICTION := .7
var can_thrust:=true
var thrust_factor := 0.0
const ROTATE_SPEED:=2.5
func _physics_process(delta: float) -> void:
	var rotate_input:float = Input.get_axis("rotate_left","rotate_right")
	if rotate_input:
		rotation+=rotate_input*ROTATE_SPEED*delta
		#apply_torque(rotate_input*torque)#*delta)
	#apply_force(linear_velocity*-1*FRICTION)

	if can_thrust and Input.is_action_pressed("move_forward"):
		charge_thrust(delta)
	elif Input.is_action_just_released("move_forward"):
		do_thrust()
	if Input.is_action_just_pressed("move_back"):
		apply_impulse(Vector2.RIGHT.rotated(rotation+PI)*thrust*.2,Vector2.ZERO)
	elif Input.is_action_just_pressed("move_left"):
		apply_impulse(Vector2.RIGHT.rotated(rotation-PI/2)*thrust*.3,Vector2.ZERO)
	elif Input.is_action_just_pressed("move_right"):
		apply_impulse(Vector2.RIGHT.rotated(rotation+PI/2)*thrust*.3,Vector2.ZERO)
		
#func _unhandled_key_input(event: InputEvent) -> void:
	
func charge_thrust(delta:float):
	if thrust_factor == 0:
		thrust_factor = .2	
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		do_thrust()
	
func do_thrust():
	print("do thrust: %2f", thrust_factor)
	#var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_property(self, "scale",Vector2(.75,1),.1)
	#await tween.finished
	#apply_impulse(Vector2.RIGHT.rotated(rotation)*thrust,Vector2.ZERO)
	##tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	#tween.tween_property(self, "scale",Vector2(1,1),.02)
	#await tween.finished
	apply_impulse(Vector2.RIGHT.rotated(rotation)*thrust*thrust_factor,Vector2.ZERO)
	can_thrust=false
	$ThrustTimer.wait_time = base_thrust_timeout*thrust_factor
	thrust_factor=0
	$ThrustTimer.start()


func _on_thrust_timer_timeout() -> void:
	can_thrust=true
