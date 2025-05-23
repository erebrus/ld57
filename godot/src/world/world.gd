extends Node2D
@onready var ambient_1: AudioStreamPlayer = $Ambient1
@onready var ambient_2: AudioStreamPlayer = $Ambient2
@onready var nav: NavigationRegion2D = $NavigationRegion2D

var osi_scene:=preload("res://src/ui/off_screen_indicator.tscn")
var score:int = 0
func _ready() -> void:
	randomize()
	Events.score_changed.emit(score)
	Events.lamp_activasted.connect(_on_lamp_activated)
	Events.map_updated.connect(_on_map_updated)
	Events.indicador_requested.connect(_on_indicador_requested)

	#Events.player_noise_ping.connect(func(pos, r): Logger.debug("Player noise ping at %s range: %.2f" % [pos,r]))

func _on_indicador_requested(angle:float, dist:float):
	var osi = osi_scene.instantiate()
	$HUDLayer/HUD.add_child(osi)
	osi.display_at_angle(angle, dist)
func _on_map_updated():
	Logger.info("baking map")
	nav.bake_navigation_polygon()
func _on_lamp_activated():
	score += 1
	Events.score_changed.emit(score)
	
func _on_ambient_timer_timeout() -> void:
	if not ambient_1.playing:
		ambient_1.play()
	else:
		ambient_2.play()
