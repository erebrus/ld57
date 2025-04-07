extends StateAnimation
@export var on_detection_state:String = "Follow"
#  func _on_enter() -> void:
#  func _after_enter() -> void:
#  func _on_update(_delta) -> void:
#  func _after_update(_delta) -> void:
#  func _before_exit() -> void:
#  func _on_exit() -> void:
#  func _on_timeout(_name) -> void:
#
@export var move_distance := 0
@export var move_variance := 15.0
@export var delay_move := 1.0
var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	agent.nav_enabled=false
	agent.player_detected.connect(_on_player_detected)
	agent.arrived.connect(_on_arrived)
	agent.target_visible = false
	Logger.info("%s %s" % [agent.name, self.name])
	$"../../AnimationPlayer".play("idle")
	if agent.target_visible:
		_on_player_detected()
	await get_tree().create_timer(.1).timeout
	_on_arrived()
		
func _before_exit(_args) -> void:
	agent.player_detected.disconnect(_on_player_detected)
	agent.arrived.disconnect(_on_arrived)

func _on_update(_delta) -> void:
	pass
func _on_player_detected():
	change_state(on_detection_state)
func _on_arrived():
	if move_distance == 0:
		return
	if delay_move>0:
		await get_tree().create_timer(delay_move).timeout
	var dist = move_distance - move_variance + 2 * move_variance * randf()
	agent.sprite.flip_h = not agent.sprite.flip_h
	var wp_vect := Vector2.LEFT if agent.sprite.flip_h else Vector2.RIGHT
	wp_vect.y = randf_range(-.5,.5)
	wp_vect *= dist
	agent.face(wp_vect)
	agent.current_speed=agent.cruise_speed
	agent.target_position=agent.global_position + wp_vect
	Logger.info("%s hovering from %s to %s (%s)" % [agent.name, agent.global_position, agent.target_position, wp_vect])
