extends StateAnimation
var agent:Enemy
@export var use_stinger:=true
@export var refollow_range:=1000.0

var detection_pending:=false

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
	del_timer("check")
	agent.player_detected.disconnect(_on_player_detected)


func _on_player_detected():
	if agent.global_position.distance_to(agent.home)>refollow_range:
		Logger.info("%s detection pending " % agent.name)
		detection_pending=true
		add_timer("check",1.0)
	else:
		change_state("Follow")

func _on_timeout(_name) -> void:
	if agent.target:
		if agent.global_position.distance_to(agent.home)>refollow_range:
			add_timer("check",1.0)
			Logger.info("%s detection pending " % agent.name)
		else:
			change_state("Follow")


		
