extends Node2D

func _ready():
	spawn_actors()

func spawn_actors():
	for actor in $GameLayer/Stage/Actors.get_children():
		actor.get_node("Body").position.y = -1000
	for actor in $GameLayer/Stage/Actors.get_children():
		actor.fall()
		yield(get_tree().create_timer(1.0), "timeout")
