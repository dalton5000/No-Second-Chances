extends Node

signal voice_completed

func play(sound):
	get_player(sound).play()

func play_question(cat, idx):
	var player = get_node("Voice/"+cat).get_child(idx)
	player.play()
	yield(player,"finished")
	emit_signal("voice_completed")


func play_voice(line):
	var player = get_player("Voice/" + line)
	player.play()
	yield(player,"finished")
	emit_signal("voice_completed")

func get_player(path):
	var node = get_node(path)
	if node is AudioStreamPlayer:
		return node
	elif node is Node:
		var idx = data.attempt_numero % node.get_child_count()
		var player = node.get_child(idx)
		return player

func button_pressed():
	$click.play()

func _ready():
	randomize()
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("button_down",self,"button_pressed")
