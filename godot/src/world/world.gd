extends Node2D

func _ready() -> void:
	randomize()
	Events.player_noise_ping.connect(func(pos, r): Logger.debug("Player noise ping at %s range: %.2f" % [pos,r]))
