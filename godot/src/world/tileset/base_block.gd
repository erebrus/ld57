class_name BaseBlock extends TileMapLayer

@onready var enemy_container = $Enemies

func _ready():
	$Navigation.hide()
	

func enemy_markers() -> Dictionary[Types.EnemyType, Array]:
	var dict: Dictionary[Types.EnemyType, Array]
	for node in enemy_container.get_children():
		if node is EnemyMarker:
			var empty: Array[EnemyMarker]
			var array: Array[EnemyMarker] = dict.get_or_add(node.enemy_type, empty)
			array.append(node as EnemyMarker)
	
	return dict
	
