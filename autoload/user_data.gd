extends Node

var sound_muted = false setget set_sound_muted
var music_muted = false setget set_music_muted

var player_name = ""
var head = 0
var body = 0


var category_score = {
	"gaming":-1,
	"godot":-1,
	"suprise":-1
}

func _ready():
	load_config()

func save_config():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
#	if err == OK:
	config.set_value("settings", "sound_muted", sound_muted)
	config.set_value("settings", "music_muted", music_muted)
	config.set_value("player_data", "player_name", player_name)
	config.set_value("player_data", "player_head", head)
	config.set_value("player_data", "player_body", body)
	config.set_value("player_data", "gaming", category_score["gaming"])
	config.set_value("player_data", "godot", category_score["godot"])
	config.set_value("player_data", "surprise", category_score["surprise"])
	config.save("user://settings.cfg")
	print("saving config")

func load_config():

	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		sound_muted = config.get_value("settings", "sound_muted", false)
		music_muted = config.get_value("settings", "music_muted", false)
		player_name = config.get_value("player_data", "player_name", "")
		head = config.get_value("player_data", "player_head", "")
		body = config.get_value("player_data", "player_body", "")
		category_score["gaming"] = config.get_value("player_data", "gaming", -1)
		category_score["godot"] = config.get_value("player_data", "godot", -1)
		category_score["surprise"] = config.get_value("player_data", "surprise", -1)


func set_sound_muted(m):
	sound_muted = m
	save_config()

func set_music_muted(m):
	music_muted = m
	save_config()

func set_cat_score(cat,score):
	category_score[cat] = score
	save_config()

func reset():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	config.set_value("settings", "sound_muted", false)
	config.set_value("settings", "music_muted", false)
	config.set_value("player_data", "player_charstring", "")
	config.set_value("player_data", "gaming", -1)
	config.set_value("player_data", "godot", -1)
	config.set_value("player_data", "surprise", -1)
	config.save("user://settings.cfg")
	print("reset config")
