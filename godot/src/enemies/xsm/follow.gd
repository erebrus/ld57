extends StateAnimation
var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	agent.player_detected.connect(_on_player_on_target)
	agent.player_lost.connect(_on_player_lost)
func _before_exit(_args) -> void:
	agent.player_detected.disconnect(_on_player_on_target)
	agent.player_lost.disconnect(_on_player_lost)

func _on_update(_delta) -> void:
	agent.target_position = agent.target.global_position
	
func _on_player_lost():
	change_state("Retreat")
func _on_player_on_target():
	change_state("Attack")
