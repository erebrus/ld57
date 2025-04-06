extends TileMapLayer

func _ready():
	Logger.info("Block rect: %s" % get_boundary_rect())
	

func get_boundary_rect() -> Rect2:
	var rect = get_used_rect()
	return rect
