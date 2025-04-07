extends Enemy

@onready var xsm: State = $XSM
@onready var sfx_move: AudioStreamPlayer2D = $sfx/sfx_move
@onready var sfx_attack: AudioStreamPlayer2D = $sfx/sfx_attack

func _on_collision():
	target_position=global_position
	xsm.change_state("Idle")
	sfx_move.stop()

func _process(delta: float) -> void:
	super._process(delta)
	if current_speed==0 and sfx_move.playing:
		sfx_move.stop()
	
func hurt_player():
	super.hurt_player()
	sfx_attack.play()
