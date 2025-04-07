class_name BaseBlock extends TileMapLayer

var rng: RandomNumberGenerator
var enemy_scenes: Dictionary[Types.EnemyType, PackedScene]

@onready var enemy_container = $Enemies

func _ready():
	$Navigation.hide()
	_place_enemies()
	

func _place_enemies() -> void:
	for node in enemy_container.get_children():
		if not node is EnemyMarker:
			continue
		
		var marker: EnemyMarker = node
		
		if not marker.enemy_type in enemy_scenes:
			Logger.warn("Could not find scene for enemy marker of type %s" % Types.EnemyType.keys()[marker.enemy_type])
			continue
		
		if rng.randf() < Globals.enemy_probability:
			var enemy: Enemy = enemy_scenes[marker.enemy_type].instantiate()
			add_child(enemy)
			
			if marker.flip_h:
				enemy.face(Vector2.LEFT)
	
