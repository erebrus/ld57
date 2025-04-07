@tool
class_name EldritchLamp extends Node2D

@export var base_energy:=1.0
@export var lit:float = 0.0:
	set(_val):
		lit=_val
		if $Sprite2DLit:
			print("set sprite lit")
			$Sprite2DLit.modulate.a=lit
		if $PointLight2D:
			print("set light energy")
			$PointLight2D.energy=base_energy*lit
			

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_lit: Sprite2D = $Sprite2DLit
@onready var light: PointLight2D = $PointLight2D


func _process(delta: float) -> void:
	lit=(abs(sin(Time.get_ticks_msec()/1000.0)))
