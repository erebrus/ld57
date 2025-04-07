class_name BaseBlock extends TileMapLayer

var lamp_enabled: bool:
	set(value):
		lamp_enabled = value
		$EldritchLamp.enabled = value
	

@onready var enemy_container = $Enemies
@onready var krill_container = $Krill


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
	

func krill_markers() -> Array[Marker2D]:
	var array: Array[Marker2D]
	for node in krill_container.get_children():
		if node is Marker2D:
			array.append(node as Marker2D)
	return array
	
