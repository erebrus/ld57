extends Enemy
@onready var sprite: Sprite2D = $Sprite2D

@onready var xsm: State = $XSM
@onready var sfx_move: AudioStreamPlayer2D = $sfx/sfx_move
@onready var sfx_attack: AudioStreamPlayer2D = $sfx/sfx_attack
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	animation_player.play("attack")

func face(target_direction:Vector2 ):
	super.face(target_direction)
	$Polygon2D.position.x =abs($Polygon2D.position.x) * (-1 if sprite.flip_h else 1)
