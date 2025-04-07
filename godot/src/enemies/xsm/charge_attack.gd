extends StateAnimation



var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	Logger.info("%s %s" % [agent.name, self.name])
	var agent_target = agent.target
	if agent_target:
		$"../../AnimationPlayer".play("move")
		agent.nav_enabled = false
		var delta_vector = (agent_target.global_position-agent.global_position)*2
		var attack_dist = clamp(delta_vector.length(), 120,900)
		agent.target_position = agent.global_position + delta_vector.normalized() * attack_dist
		agent.current_speed=agent.max_speed
		agent.player_on_target.connect(_on_player_on_target)
	else:
		change_state("Retreat")

func _before_exit(_args) -> void:
	agent.player_on_target.disconnect(_on_player_on_target)
	
func _on_update(_delta) -> void:
	if agent.has_arrived() or agent.current_speed == 0:
		if agent.target:
			change_state("Align")
		else:
			change_state("Retreat")

func _on_player_on_target():
	if agent.is_player_on_target():
		agent.hurt_player()

		
