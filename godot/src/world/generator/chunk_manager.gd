extends Node

@export var seed:int = 0
@export var player:Player
@export var cell_size:=Vector2(1280, 720)
@export var load_radius:=1
@export var unload_radius:=2
@export var chunk_container:Node2D
var rng:RandomNumberGenerator = RandomNumberGenerator.new()

var seed_matrix:Dictionary[Vector2i, int] = {}
var chunk_matrix:Dictionary[Vector2i, Node2D] = {}

func _ready():
	if seed==0:
		rng.randomize()
		seed = rng.seed
	Logger.info("Seed: %d" % seed)
	assert(player)
	assert(chunk_container)
	init_map()

func get_surrounding_cells(radius:int=1)->Array[Vector2i]:
	var cells:Array[Vector2i]=[]
	for x in range(-radius,radius+1):
		for y in range(-radius,radius+1):
			cells.append(get_player_cell()+Vector2i(x,y))
	return cells
	
	
func init_map():
	check_for_creation()
	

func get_player_cell()->Vector2i:
	return (player.global_position/cell_size)
	

func check_for_creation():
	var pcell := get_player_cell()
	for cell in get_surrounding_cells(load_radius):
		if not cell in seed_matrix:
			seed_matrix[cell]=rng.randi()
			Logger.info("Generated seed %d for %s" % [seed_matrix[cell],cell])

		if not cell in chunk_matrix:
			load_chunk(cell)

func load_chunk(cell:Vector2i):
	var chunk = Node2D.new() #TODO implement
	
	
	chunk_matrix[cell] = chunk	
	var chunk_pos := Vector2(cell_size.x*cell.x, cell_size.y*cell.y)
	chunk.global_position = chunk_pos
	chunk_container.add_child(chunk)
	Logger.info("Loaded chunk at %s with seed %d at %s" % [cell,seed_matrix[cell], chunk_pos])

	
func check_for_unload():
	var cells_to_keep := get_surrounding_cells(unload_radius)
	for cell in chunk_matrix.keys():
		if not cell in cells_to_keep:
			var chunk = chunk_matrix[cell]			
			chunk_matrix.erase(cell)
			chunk.queue_free()
			Logger.info("Unloaded chunk at %s" % cell)
		

			
func _on_timer_timeout() -> void:
	check_for_creation()
	check_for_unload()
