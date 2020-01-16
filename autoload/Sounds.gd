extends Node


func play(sound):
	get_node(sound).play()


func button_pressed():
	$click.play()

func _ready():
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("button_down",self,"button_pressed")
