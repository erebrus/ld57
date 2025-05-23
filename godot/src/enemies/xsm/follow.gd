extends StateAnimation
var agent:Enemy
@export var trigger_stinger:=true
@export var retreat_range:=1750.0

func _on_enter(_args) -> void:
	agent = target
	agent.nav_enabled = false
	Logger.info("%s %s" % [agent.name, self.name])
	agent.player_on_target.connect(_on_player_on_target)
	agent.player_lost.connect(_on_player_lost)
	agent.current_speed = agent.max_speed
	$"../../AnimationPlayer".play("follow")
	
	if agent.target:
		agent.target.stingers+=1
		Globals.use_stinger=true
		Globals.music_manager.change_game_music_to(Types.GameMusic.HARD)
		
func _before_exit(_args) -> void:
	agent.player_on_target.disconnect(_on_player_on_target)
	agent.player_lost.disconnect(_on_player_lost)

func _on_update(_delta) -> void:
	agent.current_speed = agent.max_speed
	track_player()
	if agent.global_position.distance_to(agent.home)> retreat_range:
		change_state("Retreat")

	
func _on_player_lost():
	change_state("Retreat")
func _on_player_on_target():
	change_state("Attack")


func _on_nav_timer_timeout() -> void:
	if is_active(name):
		track_player()

func track_player():
	agent.target_position = agent.target.global_position

	
