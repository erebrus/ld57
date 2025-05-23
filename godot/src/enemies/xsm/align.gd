extends StateAnimation

@export var charge_duration:float=3.0

var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	agent.player_lost.connect(_on_player_lost)
	Logger.info("%s %s" % [agent.name, self.name])
	$"../../AnimationPlayer".play("idle")
	add_timer("charge", charge_duration)
	
func _before_exit(_args) -> void:
	agent.player_lost.disconnect(_on_player_lost)
	del_timer("charge")
	
func _on_update(_delta) -> void:
	if not agent.target_visible or not agent.target:
		change_state("Retreat")
	else:
		agent.face(agent.target.global_position)
		
	
func _on_player_lost():
	change_state("Retreat")

func _on_timeout(_name) -> void:
	change_state("ChargeAttack")
		
