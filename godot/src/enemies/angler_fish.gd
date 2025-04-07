class_name AnglerFish extends Enemy
@onready var xsm: State = $XSM

@onready var sprite: Sprite2D = $Sprite2D
@onready var lure: Node2D = $Sprite2D/LureAnchor
func _ready():
	super._ready()
	nav_enabled=true

func hurt_player():
	target.kill()


func face(target_direction:Vector2 ):
	super.face(target_direction)
	lure.position.x = abs(lure.position.x) * (-1 if sprite.flip_h else 1)

	#lure.position.x =abs(lure.position.x) * (-1 if sprite.flip_h else 1)

func pounce():
	var tween:=create_tween().set_trans(Tween.TRANS_LINEAR)
	var direction=-1 if sprite.flip_h else 1
	tween.tween_property(sprite, "position", Vector2(direction*10,0),.2)
	tween.tween_property(sprite, "position", Vector2(direction*80,0),.1)
	tween.tween_property(sprite, "position", Vector2(direction*160,0),.1)
	tween.tween_property(sprite, "position", Vector2(0,0),.5)

func adjust_lure_position(lure_position:Vector2):
	lure.position.x =abs(lure_position.x) * (-1 if sprite.flip_h else 1)
