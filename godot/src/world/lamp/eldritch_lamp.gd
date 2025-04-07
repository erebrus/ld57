@tool
class_name EldritchLamp extends Node2D

@export var enabled: bool:
	set(value):
		enabled = value
		visible = enabled
	

@export var base_energy:=1.0
@export var lit:float = 0.0:
	set(_val):
		lit=_val
		if $Sprite2DLit:
			#print("set sprite lit")
			$Sprite2DLit.modulate.a=lit
		if $PointLight2D:
			#print("set light energy")
			$PointLight2D.energy=base_energy*lit
			

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_lit: Sprite2D = $Sprite2DLit
@onready var light: PointLight2D = $PointLight2D
@onready var ping_timer: Timer = $PingTimer
@onready var attach_area_2d: Area2D = $AttachArea2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var sfx_ping: AudioStreamPlayer2D = $sfx/sfx_ping
@onready var sfx_on: AudioStreamPlayer2D = $sfx/sfx_on


func _process(_delta: float) -> void:
	#lit=(abs(sin(Time.get_ticks_msec()/1000.0)))
	pass

func is_activated()->bool:
	return lit == 1.0
	
func activate()->void:
	if not enabled:
		return
	
	var tween=create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self,"lit",1,.3)
	sfx_on.play()
	ping_timer.stop()
	
func _on_ping_timer_timeout() -> void:
	if enabled:
		sfx_ping.play()


func _on_attach_area_2d_body_entered(body: Node2D) -> void:
	if enabled:
		body.lamp=self


func _on_attach_area_2d_body_exited(body: Node2D) -> void:
	if enabled:
		body.lamp=null
	
func get_attach_position()->Vector2:
	return marker_2d.global_position
