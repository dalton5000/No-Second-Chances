extends Control

signal create_pressed
signal category_selected

var created = false

func character_created():
	$Actor.set_name_and_looks(user_data.player_name,user_data.body,user_data.head)
	$Actor.anims.play("Fall")
	$Actor.show_name(true)
	created = true

func _ready():
	$Showmaster/ShowmasterAnim.play("groove")

func _on_SurpriseButton_pressed():
	emit_signal("category_selected", "surprise")


func _on_GodotButton_pressed():
	emit_signal("category_selected", "godot")


func _on_GamingButton_pressed():
	emit_signal("category_selected", "gaming")


func _on_CreateCharacterButton_pressed():
	emit_signal("create_pressed")


func _on_Wave_timeout():
	if created:
		$Actor.anims.play("Wave")
