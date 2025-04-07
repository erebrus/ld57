extends BaseBlock

func _ready():
	super._ready()
	Events.lamp_activasted.connect(_on_lamp_activated)
	
func _on_lamp_activated():
	$LampTutorial.hide()
