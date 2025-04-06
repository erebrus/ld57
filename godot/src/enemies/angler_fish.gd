class_name AnglerFish extends Enemy
@onready var xsm: State = $XSM

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	super._ready()
	nav_enabled=true

func hurt_player():
	target.kill()

func pounce():
	var tween:=create_tween().set_trans(Tween.TRANS_LINEAR)
	var direction=-1 if sprite.flip_h else 1
	tween.tween_property(sprite, "position", Vector2(direction*10,0),.2)
	tween.tween_property(sprite, "position", Vector2(direction*80,0),.1)
	tween.tween_property(sprite, "position", Vector2(direction*160,0),.1)
	tween.tween_property(sprite, "position", Vector2(0,0),.5)
