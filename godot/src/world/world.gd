extends Node2D
@onready var ambient_1: AudioStreamPlayer = $Ambient1
@onready var ambient_2: AudioStreamPlayer = $Ambient2

func _ready() -> void:
	randomize()
	Events.player_noise_ping.connect(func(pos, r): Logger.debug("Player noise ping at %s range: %.2f" % [pos,r]))


func _on_ambient_timer_timeout() -> void:
	if not ambient_1.playing:
		ambient_1.play()
	else:
		ambient_2.play()
