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


var agent:Enemy
func _on_enter(_args) -> void:
	agent = target
	agent.player_detected.connect(_on_player_detected)
	agent.target_visible = false
	Logger.info("%s %s" % [agent.name, self.name])
	$"../../AnimationPlayer".play("idle")
	if agent.target_visible:
		_on_player_detected()
func _before_exit(_args) -> void:
	agent.player_detected.disconnect(_on_player_detected)

func _on_update(_delta) -> void:
	pass
func _on_player_detected():
	change_state(on_detection_state)
