extends StateAnimation


var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	agent.player_on_target.connect(_on_player_detected)
	Logger.info("%s %s" % [agent.name, self.name])
	$"../../AnimationPlayer".play("idle")

func _before_exit(_args) -> void:
	agent.player_on_target.disconnect(_on_player_detected)

func _on_player_detected():
	change_state("TrapAttack")
