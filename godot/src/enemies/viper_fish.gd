extends Enemy

@onready var xsm: State = $XSM

func _on_collision():
	target_position=global_position
	xsm.change_state("Idle")
