extends StateAnimation

@export var hurt_timebox:Vector2 = Vector2(.1,.2)

var agent:Enemy

func _on_enter(_args) -> void:
	agent = target
	Logger.info("%s %s" % [agent.name, self.name])
	add_timer("attack", hurt_timebox.x)
	$"../../AnimationPlayer".play("attack")	
	await $"../../AnimationPlayer".animation_finished
	change_state("TrapIdle")
#func _on_anim_finished():
	#change_state("Retreat" if attack_success else "Follow")

func _on_timeout(_name) -> void:
	if agent.is_player_on_target():
		agent.hurt_player()
		
