extends StateAnimation



var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	Logger.info("%s %s" % [agent.name, self.name])
	$"../../AnimationPlayer".play("move")
	agent.nav_enabled = false
	agent.target_position = agent.global_position+(agent.target.global_position-agent.global_position)*2
	agent.current_speed=agent.max_speed
	agent.player_on_target.connect(_on_player_on_target)

func _before_exit(_args) -> void:
	agent.player_on_target.disconnect(_on_player_on_target)
	
func _on_update(_delta) -> void:
	if agent.has_arrived() or agent.current_speed == 0:
		change_state("Idle")

func _on_player_on_target():
	if agent.is_player_on_target():
		agent.hurt_player()

		
