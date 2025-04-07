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
@export var energy_per_thrust:=4.0
@export var no_energy_factor:=.5
@export var min_intensity:=.2
@export var max_intensity:=1.2
@export_category("sanity")
@export var min_energy_with_lamp:= 40
@export var min_energy_without_lamp:= 60
@export var sanity_loss:= 2.0
@export var sanity_recovery:= 5.0
@export var lamp_distance:=3000.0
#@export_category("noise")
#@export var noise_range:float = 600.0
#@export var thrust_noise_curve:Curve


var lamp:EldritchLamp
var in_animation:=false
var can_thrust:=true
var thrust_factor := 0.0
var last_thrust_direction:=Vector2.RIGHT
var currents:int:
	set(_val):
		var has_current = currents > 0
		currents=_val
		if has_current and currents ==0:
			Logger.debug("leaving current %d" % currents)
			var vol=loop_current_sfx.volume_db
			var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(loop_current_sfx,"volume_db",-40,.3)
			await tween.finished
			loop_current_sfx.stop()
			loop_current_sfx.volume_db = vol
		elif not has_current and currents > 0:
			#enter_current_sfx.play()
			#await enter_current_sfx.finished
			
			var vol=loop_current_sfx.volume_db
			loop_current_sfx.volume_db = -40
			loop_current_sfx.play()
			var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(loop_current_sfx,"volume_db",vol,.3)
			await tween.finished
			
			Logger.debug("entering current %d" % currents)
			
			if currents >0:
				loop_current_sfx.play()
	
@onready var sanity:float = 100			
@onready var energy:float = max_energy:
	set(_energy):
		energy = _energy
		if light:
			light.energy = min_intensity+ energy/max_energy*max_intensity
		
@onready var eldritch_death: Node2D = $EldritchDeath

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var light: PointLight2D = $PointLight2D

@onready var charge_sfx: AudioStreamPlayer2D = $sfx/charge_sfx
@onready var tap_sfx: AudioStreamPlayer2D = $sfx/tap_sfx
@onready var thrust_sfx: AudioStreamPlayer2D = $sfx/thrust_sfx
@onready var enter_current_sfx: AudioStreamPlayer2D = $sfx/enter_current_sfx
@onready var loop_current_sfx: AudioStreamPlayer2D = $sfx/loop_current_sfx
@onready var hurt_sfx: AudioStreamPlayer2D = $sfx/hurt_sfx
@onready var krill_sfx: AudioStreamPlayer2D = $sfx/krill_sfx
@onready var ruffle_sfx: AudioStreamPlayer2D = $sfx/ruffle_sfx
var stingers:=0

func _ready():
	energy=max_energy
	animation_player.play("idle")
	Events.eldrith_death_requested.connect(func():energy=0)
	Events.retreat_stinger.connect(func():stingers-=1)
func has_energy():
	return energy > 0 
	
func _physics_process(delta: float) -> void:
	if in_animation or eldritch_death.triggered:
		return
	if energy == 0.0:
		await eldritch_death.trigger()
		await get_tree().create_timer(1).timeout
		Globals.do_lose()
	var rotate_input:float = Input.get_axis("rotate_left","rotate_right")
	if rotate_input:
		rotation += rotate_input * rotation_speed * delta

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
		elif Input.is_action_just_pressed("interact"):
			attach()
			
func charge_thrust(delta:float):
	if thrust_factor == 0:
		thrust_factor = .2	
		animation_player.play("charge")
		Logger.debug("start charge %d" %  Time.get_ticks_msec())
		charge_sfx.play()
	else:
		thrust_factor+=delta*thrust_charge_speed
	if thrust_factor >=1.0:
		last_thrust_direction = Vector2.RIGHT
		do_thrust()
	
func do_thrust(rotation_delta:float = 0):
	var thrust_direction=Vector2.RIGHT.rotated(rotation+rotation_delta)
	Logger.debug("thrust %d" % Time.get_ticks_msec())
	if thrust_factor > .5:
		thrust_sfx.play()
	else:
		tap_sfx.play()
	if not has_energy():
		thrust_factor *= no_energy_factor
	var intensity:float = thrust * thrust_factor * (full_thrust_bonus if thrust_factor>=1.0 else 1)
	Logger.debug("thrust intensity %.2f" % intensity)
	apply_impulse(thrust_direction * intensity,Vector2.ZERO)
	#do_noise()
	can_thrust=false
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

			
	$ThrustTimer.wait_time = max(min_thrust_timeout, base_thrust_timeout*thrust_factor *( 1 if has_energy() else 1.0/no_energy_factor))
	Logger.info("wait time %.2f" % $ThrustTimer.wait_time )
	drain(energy_per_thrust*thrust_factor)
	thrust_factor=0
	$ThrustTimer.start()
	Logger.debug("thrust NOT available %d" % Time.get_ticks_msec())

#func do_noise():
	#Events.player_noise_ping.emit(global_position, noise_range*thrust_factor)
	
func _on_thrust_timer_timeout() -> void:
	can_thrust=true
	Logger.debug("thrust available %d" % Time.get_ticks_msec())
	match last_thrust_direction:		
		Vector2.RIGHT:
			if not Input.is_action_pressed("move_forward"):
				animation_player.play("thrust_to_idle")
				await animation_player.animation_finished
				animation_player.play("idle")
		_:
			animation_player.play("idle")

	

func drain(val:float):
	energy = max(0, energy-val)
	Logger.info("light %.2f/%.2f" % [energy, light.energy])

func consume(krill:Krill):
	krill_sfx.play()
	energy = min(max_energy, energy+krill.energy)
	Logger.info("light %.2f/%.2f" % [energy, light.energy])

func hurt(dmg:float):
	drain(dmg)
	hurt_sfx.play()
	#TODO stop?

func kill():
	Logger.info("hurt")
	visible=false
	hurt_sfx.play()
	await get_tree().create_timer(1).timeout
	Globals.do_lose()

func on_ruffle():
	if not ruffle_sfx.playing:
		ruffle_sfx.play()

func attach():
	if not lamp:
		return
	in_animation=true
	sleeping=true
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"global_position", lamp.get_attach_position(),.4)
	tween.parallel().tween_property(self,"global_rotation",-PI/2,.4)
	await tween.finished
	animation_player.play("attach")
	charge_sfx.play()
	await animation_player.animation_finished
	lamp.activate()
	await get_tree().create_timer(.4).timeout
	animation_player.play("dettach")
	await animation_player.animation_finished
	in_animation=false
	sleeping=false
	#await get_tree().create_timer(.1).timeout
	thrust_factor=.6
	last_thrust_direction = Vector2.RIGHT
	do_thrust()


func _on_sanity_timer_timeout() -> void:
	var has_lamp:=false
	for lamp in get_tree().get_nodes_in_group("lamp"):
		if global_position.distance_to(lamp.global_position) and lamp.is_activated():
			has_lamp=true
			break
	#if has_lamp:
		#if energy>min_energy_with_lamp:
			#recover_sanity(energy>min_energy_without_lamp)
		#else:
			#lose_sanity()
	#else:
		#if energy>min_energy_without_lamp:
			#recover_sanity()
		#else:
			#lose_sanity(energy<min_energy_with_lamp)
	#Globals.difficulty=1-sanity/100.0
	#if sanity <60 and energy <50:
	if energy < 40 and not has_lamp:
		Globals.use_stinger=false
		Globals.music_manager.change_game_music_to(Types.GameMusic.HARD)
	elif stingers==0:
		Globals.music_manager.change_game_music_to(Types.GameMusic.NORMAL)
		
	#Logger.info("sanity:%d" % sanity)
	
	
func lose_sanity(bonus:bool=false):
	var delta = sanity_loss*1 if not bonus else 2
	sanity = max(sanity-delta, 0)
func recover_sanity(bonus:bool=false):
	var delta = sanity_recovery*1 if not bonus else 2
	sanity = min(sanity+delta, 100)
	
