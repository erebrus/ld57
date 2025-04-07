class_name Chunk extends Node2D


@export var show_borders:= true

@export var krill_scene: PackedScene 


@export_category("Currents")
@export var current_scene: PackedScene
@export var min_current_intensity:= 20
@export var max_current_intensity:= 100
@export var min_currents:=2
@export var max_currents:=10
@export var min_width:=100
@export var max_width:=1000
@export var min_length:=500
@export var max_length:=2000


@export_category("Enemies")
@export var enemy_scenes: Dictionary[Types.EnemyType, PackedScene]

var size: Vector2
var rng: RandomNumberGenerator
var block: BaseBlock

@onready var tile_size = block.tile_set.tile_size
@onready var min_current_size = Vector2i(min_width / tile_size.x, min_length / tile_size.y)

func _ready():
	_place_enemies()
	_place_currents()
	_place_krill()
	
	block.lamp_enabled = block.is_tutorial or rng.randf() < Globals.lamp_probability
	

func _draw() -> void:
	if not Debug.debug_build or not show_borders:
		return
	
	draw_rect(Rect2(Vector2.ZERO, size), Color.RED, false, 2)
	draw_line(Vector2(size.x/2, 0), Vector2(size.x/2, size.y), Color.BEIGE, 2)
	draw_line(Vector2(0, size.y/2), Vector2(size.x, size.y/2), Color.BEIGE, 2)
	

func _place_enemies() -> void:
	var markers_by_type = block.enemy_markers()
	for type in markers_by_type:
		if not type in enemy_scenes:
			Logger.warn("Could not find scene for enemy marker of type %s" % Types.EnemyType.keys()[type])
			continue
		
		var markers = markers_by_type[type]
		var num_enemies = _random_number(Globals.enemy_probabilities[type], markers.size())
		
		for i in num_enemies:
			var random_marker = rng.randi() % markers.size()
			var marker = markers.pop_at(random_marker)
			
			var enemy: Enemy = enemy_scenes[type].instantiate()
			marker.add_child(enemy)
			
			if marker.flip_h:
				enemy.face(Vector2.LEFT)
				
			if type == Types.EnemyType.EEL:
				enemy.rotate(PI/2)
	

func _place_currents() -> void:
	if block.is_tutorial:
		return
	for i in rng.randi_range(min_currents, max_currents):
		_place_current()
	

func _place_current() -> void:
	var current: Current = current_scene.instantiate()
	for i in 10:
		var point = Vector2(rng.randf() * size.x, rng.randf() * size.y)
		if _is_position_free(point):
			current.position = point
			current.size = Vector2(rng.randf_range(min_width, max_width), rng.randf_range(min_length, max_length))
			current.direction = Vector2.RIGHT.rotated(rng.randf() * PI * 2)
			current.intensity = rng.randf_range(min_current_intensity, max_current_intensity)
			
			add_child(current)
			Logger.info("Placed current at %s facing %s at intensity %s" % [current.global_position, current.direction, current.intensity])
			
			return
	
	Logger.warn("Failed to place current")
	

func _place_krill() -> void:
	var markers = block.krill_markers()
	var num_krill = _random_number(Globals.krill_probability, markers.size())
	for i in num_krill:
		var random_marker = rng.randi() % markers.size()
		var marker = markers.pop_at(random_marker)
		var krill: Krill = krill_scene.instantiate()
		marker.add_child(krill)
	

func _is_position_free(point: Vector2) -> bool:
	return true
	

func _random_number(probability: float, quantity: int) -> int:
	if block.is_tutorial:
		return quantity
	
	var random = probability * quantity
	var min = floor(random)
	if rng.randf() < random - min:
		return min + 1
	else:
		return min
		
