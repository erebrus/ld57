@tool
extends Node

const CELL_SIZE = 64
const SCREEN_SIZE = Vector2i(1280, 720)
const CHUNK_MARGIN = 4 * CELL_SIZE

@export var seed:int = 0
@export var player:Player
@export var cell_size:=Vector2(1280, 720)
@export var load_radius:=1
@export var unload_radius:=2
@export var chunk_container:Node2D

@export_tool_button("Calculate Cell Size", "Callable") var calculate_cell_size = _calculate_cell_size
@export var ChunkScene: PackedScene
@export var start_block: PackedScene
@export var blocks: Array[PackedScene]
@export var enemies: Dictionary[Types.EnemyType, PackedScene]
@export var enabled:=true

var rng:RandomNumberGenerator = RandomNumberGenerator.new()

var seed_matrix:Dictionary[Vector2i, int] = {}
var chunk_matrix:Dictionary[Vector2i, Node2D] = {}

func _ready():
	if Engine.is_editor_hint() or not enabled:
		return
	
	if seed==0:
		rng.randomize()
		seed = rng.seed
	
	Logger.info("Seed: %d" % seed)
	assert(player)
	assert(chunk_container)	
	init_map()
	await get_tree().process_frame
	Events.map_updated.emit()
	

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
	var map_needs_update:=false
	for cell in get_surrounding_cells(load_radius):
		if not cell in seed_matrix:
			seed_matrix[cell]=rng.randi()
			Logger.info("Generated seed %d for %s" % [seed_matrix[cell],cell])

		if not cell in chunk_matrix:
			load_chunk(cell)
			map_needs_update=true
			
	if map_needs_update:
		Events.map_updated.emit()
	

func load_chunk(cell:Vector2i):
	var chunk_rng = RandomNumberGenerator.new()
	chunk_rng.seed = seed_matrix[cell]
	
	var chunk: Chunk = ChunkScene.instantiate()
	chunk.size = cell_size
	chunk.rng = chunk_rng
	var chunk_pos := Vector2(cell_size.x*cell.x, cell_size.y*cell.y)
	chunk.global_position = chunk_pos
	Logger.info("Generating chunk %s at %s" % [cell, chunk_pos])
	
	var block_scene = start_block if cell == Vector2i.ZERO else blocks[chunk_rng.randi() % blocks.size()]
	var block: BaseBlock = block_scene.instantiate()
	var block_rect = block.get_used_rect()
	
	var max_offset = cell_size / 2 - block_rect.size * CELL_SIZE / 2.0 - CHUNK_MARGIN / 2 * Vector2.ONE
	
	var offset: Vector2
	
	if cell == Vector2i.ZERO:
		offset.x = CELL_SIZE * -5
		offset.y = CELL_SIZE * -4
	else:
		offset.x = chunk_rng.randi_range(-max_offset.x, max_offset.x)
		offset.y = chunk_rng.randi_range(-max_offset.y, max_offset.y)
	
	block.position = cell_size / 2 - block_rect.get_center() * float(CELL_SIZE) + offset
	chunk.block = block
	chunk.add_child(block) 
	
	chunk_matrix[cell] = chunk
	chunk_container.add_child(chunk)
	Logger.info("Loaded chunk (%s) at %s with seed %d at %s" % [block.name,cell,seed_matrix[cell], chunk_pos])
	
	

func check_for_unload():
	var cells_to_keep := get_surrounding_cells(unload_radius)
	for cell in chunk_matrix.keys():
		if not cell in cells_to_keep:
			var chunk = chunk_matrix[cell]			
			chunk_matrix.erase(cell)
			chunk.queue_free()
			Logger.info("Unloaded chunk at %s" % cell)
		

func _calculate_cell_size() -> void:
	var max_block_size = Vector2i.ZERO
	for scene in blocks:
		var block: BaseBlock = scene.instantiate()
		var size = block.get_used_rect().size
		print("Loaded block %s with size %s" % [scene.resource_path.get_file(), size])
		
		max_block_size.x = max(size.x, max_block_size.x)
		max_block_size.y = max(size.y, max_block_size.y)
		
	cell_size.x = max(SCREEN_SIZE.x, max_block_size.x * CELL_SIZE + CHUNK_MARGIN)
	cell_size.y = max(SCREEN_SIZE.y, max_block_size.y * CELL_SIZE + CHUNK_MARGIN)
	

func _on_timer_timeout() -> void:
	if not enabled:
		return 
	check_for_creation()
	check_for_unload()
