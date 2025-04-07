extends Node2D

@export var player:Player
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var triggered:=false
func trigger():
	global_rotation=0
	if triggered:
		return
	triggered=true
	animation_player.play("default")
	await animation_player.animation_finished

func hide_player():
	player.visible=false
