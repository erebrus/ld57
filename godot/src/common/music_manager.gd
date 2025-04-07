class_name MusicManager extends Node


@export var default_music_volume:float = -8.0
@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var game_music: AudioStreamPlayer = $game_music
@onready var panic_music: AudioStreamPlayer = $panic_music
@onready var stinger: AudioStreamPlayer = $stinger


#@onready var game_music_stream := game_music.stream
var current_game_music_id = Types.GameMusic.NORMAL



func fade_in_menu_music(time:float=1.0):
	fade_in_stream(menu_music,time)

func fade_menu_music(time:float=1.0):
	fade_stream(menu_music, time)
	
func fade_in_game_music(time:float=1.0):
	fade_in_stream(game_music, time)

func fade_game_music(time:float=1.0):
	fade_stream(game_music, time)
		
func play_music(node:AudioStreamPlayer):
	if not node.playing:
		node.play()
	
#func reset_synchronized_stream():
	#for i in range(game_music_stream.stream_count):
		#if i == current_game_music_id:
			#game_music_stream.set_sync_stream_volume(i,0)
		#else:
			#game_music_stream.set_sync_stream_volume(i,-60)

func fade_in_stream(node:AudioStreamPlayer, duration := 1.0):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	node.volume_db=-20
	node.play()
	tween.tween_property(node,"volume_db",default_music_volume , duration)
	await tween.finished
	Logger.info("%s playing %s volume:%f" % [node.name, node.playing, node.volume_db])

func fade_stream(node:AudioStreamPlayer, duration := 1.0):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node,"volume_db",-20 , duration)
	await tween.finished
	node.stop()
	

#func _helper_set_volume(volume_db:float, id:int):
	#game_music_stream.set_sync_stream_volume(id, volume_db)
	

func change_game_music_to(new_id:Types.GameMusic, time:=1.0):
	if new_id == current_game_music_id:
		return
	var current = panic_music if new_id==Types.GameMusic.NORMAL else game_music
	var next = game_music if new_id==Types.GameMusic.NORMAL else panic_music
	fade_in_stream(next)
	fade_stream(current)
	if new_id == Types.GameMusic.HARD:
		stinger.play()
	current_game_music_id = new_id
	Logger.info("Music changed to: %s" % new_id)
