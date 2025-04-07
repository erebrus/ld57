extends StateAnimation
var agent:Enemy
@export var use_stinger:=false

func _on_enter(_args) -> void:
	agent = target
	agent.nav_enabled = true
	Logger.info("%s %s" % [agent.name, self.name])
	agent.player_detected.connect(_on_player_detected)
	agent.target_position = agent.home
	agent.current_speed = agent.cruise_speed
	$"../../AnimationPlayer".play("retreat")
	if agent.target:
		Events.retreat_stinger.emit()

func _before_exit(_args) -> void:
	agent.player_detected.disconnect(_on_player_detected)


func _on_player_detected():
	change_state("Follow")
