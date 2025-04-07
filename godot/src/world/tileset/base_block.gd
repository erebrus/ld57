class_name BaseBlock extends TileMapLayer

@onready var enemy_container = $Enemies

func _ready():
	$Navigation.hide()
	

func enemy_markers() -> Array[EnemyMarker]:
	var array: Array[EnemyMarker]
	for node in enemy_container.get_children():
		if node is EnemyMarker:
			array.append(node as EnemyMarker)
	
	return array
	
