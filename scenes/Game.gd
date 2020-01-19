extends Node2D
class_name Game

signal speech_complete



var current_question = 8 setget set_current_question
var given_answer = 0

onready var counter_label = $GameLayer/HUD/CounterPanel/CounterLabel

onready var answer_buttons = [
	$GameLayer/HUD/QuestionPanel/VBoxContainer/HBoxContainer/Button,
	$GameLayer/HUD/QuestionPanel/VBoxContainer/HBoxContainer/Button2,
	$GameLayer/HUD/QuestionPanel/VBoxContainer/HBoxContainer2/Button,
	$GameLayer/HUD/QuestionPanel/VBoxContainer/HBoxContainer2/Button2
]

var active_category = ""

onready var cat_buttons = [
	$TitleLayer/Title/VBoxContainer/CategoryButtons/GamingButton,
	$TitleLayer/Title/VBoxContainer/CategoryButtons/GodotButton,
	$TitleLayer/Title/VBoxContainer/CategoryButtons/SurpriseButton]

onready var cat2button = {
	"gaming" : cat_buttons[0],
	"godot" : cat_buttons[1],
	"surprise" : cat_buttons[2]
	}

var answers_given = {
	"gaming" : [],
	"godot" : [],
	"surprise" : []
}

onready var question_anim =$GameLayer/HUD/QuestionAnim
onready var transition = $TransitionLayer/TransitionAnimation

onready var actors = $GameLayer/Stage/Actors.get_children()
onready var player = actors[0] as Actor

onready var speech_label = $GameLayer/HUD/SpeechPanel/Label
onready var speech_tween = $GameLayer/HUD/SpeechPanel/Tween
onready var speech_timer  = $GameLayer/HUD/SpeechPanel/SpeechTimer
onready var answer_label = $GameLayer/HUD/SpeechPanel/AnswerLabel

onready var question_label = $GameLayer/HUD/QuestionPanel/VBoxContainer/Label
onready var gameover_label = $GameLayer/HUD/GameOverPanel/VBoxContainer/GameOverLabel

var gameover_text_better = "You reached question %s out of 10 in category %s.\nHey, at least you did better than %s!"
var gameover_text_worst = "You reached question %s out of 10 in category %s.\nAll other candidates got further than you, how embarrassing!"
var gameover_text_best = "You reached question %s out of 10 in category %s.\nYou may be dead, but you did better than %s!"
var gameover_text_equal = "You reached question %s out of 10 in category %s.\nYou all died at the same question. Funny!"

var player_name = ""
var player_names = []

#FSM
enum STATES {MENU, INTRO, QUESTION, VALIDATION, GAMEOVER, WIN}
var active_state = STATES.MENU

func change_state(new_state):
	var last_state = active_state
	active_state = new_state


	match new_state:
		STATES.MENU:
			$Music.fade_to($Music.title_music)
			disable_categories()
			load_menu()
		STATES.INTRO:
			$Music.fade_to($Music.game_music)
			start_intro()
		STATES.QUESTION:
			set_answers_enabled()
			load_next_question()
		STATES.VALIDATION:
			set_answers_enabled(false)
			start_validation()
		STATES.GAMEOVER:
			start_gameover()



func reset_answers():
	question_label.percent_visible = 0.0
	for b in answer_buttons:
		b.modulate = Color.transparent
		b.pressed = false

func set_answers_enabled(e = true):
	for b in answer_buttons:
		b.disabled = !e

func spawn_actors():
	for actor in $GameLayer/Stage/Actors.get_children():
		actor.get_node("Body").position.y = -1000
		actor.show_name(true)
		actor.alive=true
		actor.score=0

func validate(answer):
	if data.answers[active_category][current_question][4] == answer:
		return true
	else:
		return false

func load_next_question():
	question_label.text = data.questions[active_category][current_question]
	for i in 4:
		answer_buttons[i].text = str(i+1) + ") " + data.answers[active_category][current_question][i]
	$GameLayer/HUD/QuestionAnim.play("SlideIn")
	Sounds.play_question(active_category, current_question)
	yield($GameLayer/HUD/QuestionAnim,"animation_finished")
	$GameLayer/HUD/QuestionAnim.play("ShowQuestion")
	yield(Sounds,"voice_completed")
	$GameLayer/HUD/QuestionAnim.play("ShowAnswers")

func load_menu():
	$GameLayer/Stage.hide()
	$GameLayer/HUD.hide()
	$TitleLayer/Title.show()

func start_intro():
	load_candidate_data()
	player.set_name_and_looks(user_data.player_name,user_data.body,user_data.head)
	player_name = player.player_name
	$CreatorLayer/CharacterCreator.hide()
	$GameLayer/Stage.show()
	$GameLayer/HUD.show()
	$GameLayer/HUD/QuestionPanel.rect_position.x = -1000
	spawn_actors()

	yield(get_tree().create_timer(2.5),"timeout")

###############
#	Sounds.play_voice("welcome")
#	say(data.get_line("welcome"),8.0)
#	yield(Sounds,"voice_completed")
#	$GameLayer/Stage/Showmaster.get_node("BaseAnimations").play("Wave")
#	say(data.get_line("banter"),8.0)
#	Sounds.play_voice("banter")
#	Sounds.play("applause2")
#	yield(Sounds,"voice_completed")
#
#	say("Let\'s say hello to today\'s contender! I would tell you who they are, but they would appear to have put their namebadge on upside down.", 8.0)
#	Sounds.play_voice("hereiscandidate")
	player.fall()
#	yield(Sounds,"voice_completed")
#	actors[0].get_node("BaseAnimations").play("Wave")
#	Sounds.play("applause1")
#	say("You have chosen the category %s. Very well! Let’s see who will be your opponents." % [active_category], 6.0)
#	Sounds.play_voice("category_calls/" + active_category)
#	yield(Sounds,"voice_completed")

#	Sounds.play_voice("opponents")
#	yield(Sounds,"voice_completed")
#
#	Sounds.play_voice("interlude")
#	say(data.get_line("interlude"),4.0)
#	yield(Sounds,"voice_completed")
##########

#	yield(self,"speech_complete")
	for actor in [1,2,3,4]:
		actors[actor].fall()
		yield(get_tree().create_timer(1.0), "timeout")
	yield(get_tree().create_timer(1.0), "timeout")
#	say("Welcome %s, %s, %s and %s!" % player_names)
#	yield(self,"speech_complete")

	candidates_wave()
	Sounds.play("applause2")

#	say(data.get_line("candidate_banter"),8.0)
#	Sounds.play_voice("candidate_banter")

#	yield(Sounds,"voice_completed")

#	say("Here\'s your first question.\nPro Tip: Don\'t bottle it.'", 3.0)
	if current_question == 0:
		say(data.get_line("first_question"),8.0)
		Sounds.play_voice("first_question")
		yield(Sounds,"voice_completed")




	yield(get_tree().create_timer(1.2),"timeout")


	change_state(STATES.QUESTION)

func start_validation():
	Sounds.play_voice("see_answers")
	say(data.get_line("see_answers"),2.0)
	yield(Sounds,"voice_completed")
#	yield(self,"speech_complete")

	yield(get_tree().create_timer(1.0), "timeout")

#	Sounds.play("reveal")
	player.show_player_answer(given_answer)
	for i in [1,2,3,4]:
		if actors[i].alive:
			actors[i].show_answer(current_question)
	Sounds.play("drumroll")
	say("And the correct answer is...", 2.0)
	Sounds.play_voice("theansweris")
#	yield(Sounds,"voice_completed")
	yield(get_tree().create_timer(3.0), "timeout")

	Sounds.play("aah")
#	say(str(int(data.answers[active_category][current_question][4])+1) +" !!",3.0)
	var correct_idx= data.answers[active_category][current_question][4]
	answer_buttons[correct_idx].modulate = Color.lightgreen
	answer_label.text = str(correct_idx+1) +"!"
#	print(answer_label.text)
#	question_anim.play("RevealAnswer")
	yield(get_tree().create_timer(2.0), "timeout")
	answer_label.text = ""
#	yield(self,"speech_complete")

	if validate(given_answer):
		Sounds.play("correct")
		yield(get_tree().create_timer(0.6), "timeout")
		Sounds.play_voice("youarecorrect")
		say("You are correct!")
		yield(Sounds,"voice_completed")
		Sounds.play("applause1")
		question_anim.play("SlideOut")
		yield(question_anim,"animation_finished")
		answer_buttons[correct_idx].modulate = Color.white






		reset_answers()
#		if is_everyone_dead():
#			say("Let's continue with the next question")
		if not is_everyone_dead():
			if will_someone_die():
				say("That can't be said about everyone...")
				Sounds.play_voice("cantbesaid")
				yield(Sounds,"voice_completed")
			else:
				var alive = true
				for i in [1,2,3,4]:
					if actors[i].alive == false:
						alive=false
				if alive:
					say("Everyone got this one right! What a surprise!")
					Sounds.play_voice("everyoneright")
					yield(Sounds,"voice_completed")

			check_candidates()
			yield(get_tree().create_timer(0.4),"timeout")
			Sounds.play("ohmygod")
			yield(get_tree().create_timer(2.4),"timeout")

		current_question+=1
		if current_question == 4:
			Sounds.play_voice("halfway")
			yield(Sounds,"voice_completed")
			say("We are, as they say, halfway there.\nWoohoo, living on a prayer!")

		if current_question == 8:
			Sounds.play_voice("finalquestion")
			say("You have reached the final question of this category! Savour the moment of fame while it lasts.")
			yield(Sounds,"voice_completed")
		if current_question == 10:
			Sounds.play("fanfare")
			Sounds.play_voice("youdidit")
			say("You did it! That was the last question of the category. You're much smarter than you look!",6.0)

			Sounds.play_voice("youdidit")
			yield(Sounds,"voice_completed")
			say("So, there is no prize for budgetary reasons, but you can tell your friends about your success!",6.0)
#			yield(Sounds,"voice_completed")
			Sounds.play_voice("no prize")
			yield(Sounds,"voice_completed")
			start_game_won()
		else:
			change_state(STATES.QUESTION)
	else:
		Sounds.play("wrong")
		yield(get_tree().create_timer(0.8),"timeout")
		start_gameover()

func start_game_won():
	user_data.set_cat_score(active_category, 10)
	WebHandler.upload_answers(active_category, answers_given[active_category])
	gameover_label.text = "You have won category %s\n Congratulations, and thank you for playing :)" % [active_category.capitalize()]
	actors[0].get_node("BaseAnimations").play("Wave")
	question_anim.play("Win")
	candidates_wave()
	yield(get_tree().create_timer(7.0),"timeout")
	Sounds.play_voice("thatsit")

func start_gameover():
	user_data.set_cat_score(active_category, current_question)
	WebHandler.upload_answers(active_category, answers_given[active_category])
	gameover_label.text = create_gameover_text()

	Sounds.play_voice("youarewrong")
	say("Oh no! Your answer was wrong.\nYou know the deal...\nNo second Chances!\nBut thanks for participating!", 8.0)
	yield(Sounds,"voice_completed")

	Sounds.play_voice("youknowthedeal")
	yield(Sounds,"voice_completed")
#	yield(self,"speech_complete")
	check_candidates()
	question_anim.play("Fall")
	yield(get_tree().create_timer(1.0),"timeout")
	player.anims.play("Smash")
	yield(get_tree().create_timer(0.5),"timeout")
	Sounds.play("ohmygod")
	yield(get_tree().create_timer(2.0),"timeout")
	say("Goodbye and until next time!")
	candidates_wave()

	answer_buttons[data.answers[active_category][current_question][4]].modulate = Color.white
#	yield(get_tree().create_timer(5.0),"timeout")
#	change_state(STATES.MENU)

func create_gameover_text():
	var text = ""

	var better_players = []
	for i in [1,2,3,4]:
		if actors[i].score > current_question:
			better_players.append(actors[i].player_name)
	var all_equal = true
	for i in [1,2,3,4]:
		if actors[i].score != current_question:
			all_equal=false
	var names_string = ""
	match better_players.size():
		0:
			if all_equal:
				text = gameover_text_equal % [str(current_question), active_category]
			else:
				names_string = "%s, %s, %s and even %s" % player_names
				text = gameover_text_best % [str(current_question), active_category, names_string]
		1:
			names_string = "%s" % [better_players]
			text = gameover_text_better % [str(current_question), active_category, names_string]
		2:
			names_string = "%s and %s" % [better_players]
			text = gameover_text_better % [str(current_question), active_category, names_string]
		3:
			names_string = "%s, %s, and %s" % [better_players]
			text = gameover_text_better % [str(current_question), active_category, names_string]
		4:
			text = gameover_text_worst % [str(current_question), active_category]

	return text



func load_candidate_data():
	for i in 4:
		var cdata = WebHandler.lobbies[active_category]
		actors[i+1].head_frame = int(cdata[i]["head"])
		actors[i+1].body_frame = int(cdata[i]["body"])
		actors[i+1].player_name = cdata[i]["name"]
		actors[i+1].answer_list = cdata[i]["answers"]
		player_names.append(cdata[i]["name"])

func answer_pressed(idx):
	answers_given[active_category].append(idx)
	given_answer = idx
	change_state(STATES.VALIDATION)

func disable_categories():
	data.attempt_numero = 0
	for category in ["gaming","godot","surprise"]:
#		print("loaded category score: " + category)
#		print(user_data.category_score)
#		print(user_data.category_score[category])
		if user_data.category_score[category] != -1:
#			print(user_data.category_score[category])
#			print("closing")
			data.attempt_numero += 1
			cat2button[category].disabled=true
			cat2button[category].text = "%s %s / 10" % [category.capitalize(), str(user_data.category_score[category])]

		else:
			if user_data.player_name == "":
				cat2button[category].disabled=true
			else:
				cat2button[category].disabled=false
			cat2button[category].text = category.capitalize()
	print("Attempt numero: %s" % [str(data.attempt_numero)])
#	data.attempt_numero = 8
func set_current_question(q):
	current_question = q
	counter_label.text = str(q) + "/10"
func candidates_wave():
	for i in [1,2,3,4]:
		if actors[i].alive:
			actors[i].get_node("BaseAnimations").play("Wave")
			print("should wave")

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

func is_everyone_dead():
	var all_dead = true
	for i in [1,2,3,4]:
		if actors[i].alive:
			all_dead=false
	return all_dead


func will_someone_die():
	var will_die = false
	for i in [1,2,3,4]:
		if actors[i].alive:
			if int(actors[i].answer_list[current_question]) != data.answers[active_category][current_question][4]:
				will_die = true
	return will_die

func check_candidates():
	for i in [1,2,3,4]:
		if actors[i].alive:
			if int(actors[i].answer_list[current_question]) == data.answers[active_category][current_question][4]:
				actors[i].score += 1
			else:
				actors[i].anims.play("Smash")
				yield(get_tree().create_timer(0.3),"timeout")

func _on_CharacterCreator_finished():
	transition.play("FadeOut")
	yield(transition, "animation_finished")
	$CreatorLayer/CharacterCreator.hide()
	$TitleLayer/Title.show()
	$TitleLayer/Title.character_created()
	for b in cat_buttons:
		b.disabled = false
	transition.play("FadeIn")
	yield(transition, "animation_finished")

func _on_SpeechTimer_timeout():
	$GameLayer/HUD/SpeechPanel/HideTimer.start()
	emit_signal("speech_complete")

func _on_HideTimer_timeout():
	if $GameLayer/HUD/SpeechPanel.modulate != Color.transparent:
		speech_tween.interpolate_property($GameLayer/HUD/SpeechPanel, "modulate", $GameLayer/HUD/SpeechPanel.modulate,Color.transparent, 0.3,Tween.TRANS_LINEAR,Tween.EASE_IN)
		speech_tween.start()
#		yield(speech_tween,"tween_all_completed")

func _ready():
	$GameLayer/Stage.hide()
	$GameLayer/HUD.hide()
	$CreatorLayer/CharacterCreator.hide()
	$TitleLayer/Title.show()

	WebHandler.connect("connection_established",self,"on_connection_ok")
	WebHandler.connect("lobbies_loaded",self,"on_lobbies_loaded")
	WebHandler.connect("connection_failed",self,"on_connection_failed")

	if user_data.player_name != "":
		$TitleLayer/Title/VBoxContainer/CreateCharacterButton.hide()
		$TitleLayer/Title.character_created()

		for b in cat_buttons:
			b.disabled = false

	disable_categories()
	transition.play("FadeIn")
	yield(transition, "animation_finished")

	speech_label.text = ""
	$GameLayer/HUD/SpeechPanel.modulate = Color.transparent
	for i in 4:
		answer_buttons[i].connect("pressed",self, "answer_pressed", [i])


func _on_TransitionAnimation_animation_finished(anim_name):
	pass # Replace with function body.


func _on_Title_create_pressed():
	transition.play("FadeOut")
	yield(transition, "animation_finished")
	$TitleLayer/Title/VBoxContainer/CreateCharacterButton.hide()
	$CreatorLayer/CharacterCreator.show()
	$TitleLayer/Title.hide()
	transition.play("FadeIn")


func _on_Title_category_selected(category):
	if not transition.is_playing():
		active_category = category
		transition.play("FadeOut")
		yield(transition, "animation_finished")
		$TitleLayer/Title.hide()
		transition.play("FadeIn")
		change_state(STATES.INTRO)


func _on_Reset_pressed():
	user_data.reset()
	yield(get_tree().create_timer(0.2),"timeout")


func _on_MenuButton_pressed():
	transition.play("FadeOut")
	yield(transition, "animation_finished")
	get_tree().reload_current_scene()
#	$TitleLayer/Title.hide()
#	change_state(STATES.MENU)
#	transition.play("FadeIn")

func on_connection_ok():
	$TitleLayer/Title/ConnectionPanel/Label.text = "Loading Lobbies..."
	$TitleLayer/Title/ConnectionPanel/ConnectButton.hide()

func on_lobbies_loaded():
#	$TitleLayer/Title/ConnectionPanel/Label.text = "Ready to play!"
	$TitleLayer/Title/ConnectionPanel/Label.hide()

func on_connection_failed():
	$TitleLayer/Title/ConnectionPanel/Label.text = "Connection failed :( Check your firewall settings"
	$TitleLayer/Title/ConnectionPanel/ConnectButton.show()

func _on_ConnectButton_pressed():
	WebHandler.test_connection()
