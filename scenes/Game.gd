extends Node2D

signal speech_complete

var current_question = 0

onready var actors = $GameLayer/Stage/Actors.get_children()
onready var speech_label = $GameLayer/HUD/SpeechPanel/Label
onready var speech_tween = $GameLayer/HUD/SpeechPanel/Tween
onready var speech_timer  = $GameLayer/HUD/SpeechPanel/SpeechTimer

func _ready():
	speech_label.text = ""
	$GameLayer/Stage.hide()
	$GameLayer/HUD.hide()
	$CreatorLayer/CharacterCreator.show()
	$GameLayer/HUD/SpeechPanel.modulate = Color.transparent

func spawn_actors():
	for actor in $GameLayer/Stage/Actors.get_children():
		actor.get_node("Body").position.y = -1000
		actor.show_name(true)

	$GameLayer/Stage/Actors.get_children()[0].fall()


func _on_CharacterCreator_finished():
	actors[0].read_from_string(	$CreatorLayer/CharacterCreator.create_character_string())
	$CreatorLayer/CharacterCreator.hide()
	spawn_actors()
	$GameLayer/Stage.show()
	$GameLayer/HUD.show()
	say("Hello and Welcome to\n\"No Second Chances\"!",5.0)
	$GameLayer/Stage/Showmaster.get_node("BaseAnimations").play("Wave")
	yield(self,"speech_complete")
	actors[0].get_node("BaseAnimations").play("Wave")
	say("The quizshow without mercy!\nLet's see who will be your opponents",4.0)
	yield(self,"speech_complete")
	for actor in [1,2,3]:
		actors[actor].fall()
		yield(get_tree().create_timer(1.0), "timeout")
	say("Welcome Dings, Bums und Otto!")
	yield(self,"speech_complete")
	for actor in [1,2,3]:
		actors[actor].get_node("BaseAnimations").play("Wave")
	say("Here are the Rules:")
	yield(self,"speech_complete")
	say("Let's go!")
	$GameLayer/HUD/QuestionAnim.play("SlideIn")
	yield($GameLayer/HUD/QuestionAnim,"animation_finished")
	$GameLayer/HUD/QuestionAnim.play("ShowQuestion")





func say(text, wait_time = 3.0):
	speech_label.text = ""
	speech_timer.wait_time =  wait_time
	speech_label.percent_visible = 0.0
	$GameLayer/HUD/SpeechPanel/HideTimer.stop()

	if $GameLayer/HUD/SpeechPanel.modulate != Color.white:
		speech_tween.interpolate_property($GameLayer/HUD/SpeechPanel, "modulate", $GameLayer/HUD/SpeechPanel.modulate,Color.white, 0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)

#	if speech_label.percent_visible > 0.0:
#		speech_tween.interpolate_property(speech_label,"percent_visible", 1.0, 0.0,0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	speech_tween.start()
	yield(speech_tween,"tween_all_completed")
	speech_label.text= text
	speech_tween.interpolate_property(speech_label,"percent_visible", 0.0, 1.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	speech_tween.start()
	yield(speech_tween,"tween_all_completed")
	speech_timer.start()


func _on_SpeechTimer_timeout():
	$GameLayer/HUD/SpeechPanel/HideTimer.start()
	emit_signal("speech_complete")

func _on_HideTimer_timeout():
	if $GameLayer/HUD/SpeechPanel.modulate != Color.transparent:
		speech_tween.interpolate_property($GameLayer/HUD/SpeechPanel, "modulate", $GameLayer/HUD/SpeechPanel.modulate,Color.transparent, 0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		speech_tween.start()
#		yield(speech_tween,"tween_all_completed")
