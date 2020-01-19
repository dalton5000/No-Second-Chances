extends Node

signal fade_out_completed

onready var title_music = $TitleMusic
onready var game_music = $GameMusic

var current_song

func _ready():
	fade_in(title_music)


func fade_in(song):
	$Tween.interpolate_property(song, "volume_db", linear2db(0.1), linear2db(1.0), 1.5,Tween.TRANS_SINE,Tween.EASE_IN)
	current_song = song
	$Tween.start()


func fade_out():
	$Tween.interpolate_property(current_song, "volume_db", linear2db(0.1), linear2db(1.0), 1.5,Tween.TRANS_SINE,Tween.EASE_IN)
	$Tween.start()
	yield($Tween,"tween_all_completed")
	current_song.stop()
	emit_signal("fade_out_completed")


func fade_to(song):
	song.play()
	var last_song = current_song
	if current_song:
		$Tween.interpolate_property(current_song, "volume_db", current_song.volume_db, linear2db(0.1), 1.0,Tween.TRANS_SINE,Tween.EASE_IN)
	$Tween.interpolate_property(song, "volume_db", linear2db(0.1), linear2db(1.0), 1.0,Tween.TRANS_SINE,Tween.EASE_IN)
	current_song = song
	$Tween.start()
	yield($Tween,"tween_all_completed")
	last_song.stop()

