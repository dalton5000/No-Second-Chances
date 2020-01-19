extends Node

signal voice_completed

func play(sound):
	if sound == "aah":
		var s = ["aah1","aah2","aah3"][randi()%3]
		get_node(s).play()
	else:
		get_node(sound).play()

func play_question(cat, idx):
	var player = get_node("Voice/"+cat).get_child(idx)
	player.play()
	yield(player,"finished")
	emit_signal("voice_completed")


func play_voice(line):
	var player = get_node("Voice/" + line)
	player.play()
	yield(player,"finished")
	emit_signal("voice_completed")

func button_pressed():
	$click.play()

func _ready():
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("button_down",self,"button_pressed")
