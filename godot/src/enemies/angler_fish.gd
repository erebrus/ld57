class_name AnglerFish extends Enemy
@onready var xsm: State = $XSM


func _ready():
	super._ready()
	nav_enabled=true
