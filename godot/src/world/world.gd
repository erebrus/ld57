extends Node2D
@onready var ambient_1: AudioStreamPlayer = $Ambient1
@onready var ambient_2: AudioStreamPlayer = $Ambient2

var score:int = 0
func _ready() -> void:
	randomize()
	Events.score_changed.emit(score)
	Events.lamp_activasted.connect(_on_lamp_activated)
	#Events.player_noise_ping.connect(func(pos, r): Logger.debug("Player noise ping at %s range: %.2f" % [pos,r]))

func _on_lamp_activated():
	score += 1
	Events.score_changed.emit(score)
	
func _on_ambient_timer_timeout() -> void:
	if not ambient_1.playing:
		ambient_1.play()
	else:
		ambient_2.play()
