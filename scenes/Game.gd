extends Node2D
class_name Game

signal speech_complete

var current_question = 0
var given_answer = 0

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

onready var question_label = $GameLayer/HUD/QuestionPanel/VBoxContainer/Label
onready var gameover_label = $GameLayer/HUD/GameOverPanel/VBoxContainer/GameOverLabel

var gameover_text_better = "You reached question %s out of 10 in category %s.\nHey, at least you did better than %s!"
var gameover_text_worst = "You reached question %s out of 10 in category %s.\nAll other candidates got further than you, how embarrassing!"
var gameover_text_best = "You reached question %s out of 10 in category %s.\n You may be dead, but you did better than %s!"
var gameover_text_equal = "You reached question %s out of 10 in category %s.\n You all died at the same question. Funny!"

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
	player.fall()

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
	yield($GameLayer/HUD/QuestionAnim,"animation_finished")
	$GameLayer/HUD/QuestionAnim.play("ShowQuestion")

func load_menu():
	$GameLayer/Stage.hide()
	$GameLayer/HUD.hide()
	$TitleLayer/Title.show()

func start_intro():
	load_candidate_data()
	spawn_actors()
	player.set_name_and_looks(user_data.player_name,user_data.body,user_data.head)
	player_name = player.player_name
	$CreatorLayer/CharacterCreator.hide()
	spawn_actors()
	$GameLayer/Stage.show()
	$GameLayer/HUD.show()
	$GameLayer/HUD/QuestionPanel.rect_position.x = -1000
	say("Hello %s and Welcome to\n\"No Second Chances\"!" %[player_name],4.0)
	$GameLayer/Stage/Showmaster.get_node("BaseAnimations").play("Wave")
	yield(self,"speech_complete")
	actors[0].get_node("BaseAnimations").play("Wave")
	Sounds.play("applause1")
	say("The quizshow without mercy!\nLet's see who will be your opponents",3.5)
	yield(self,"speech_complete")
	for actor in [1,2,3,4]:
		actors[actor].fall()
		yield(get_tree().create_timer(1.0), "timeout")
	say("Welcome %s, %s, %s and %s!" % player_names)
	yield(self,"speech_complete")
	candidates_wave()
	Sounds.play("applause2")
#	say("Here are the Rules:")
	say("So let's get started\nwith question number one!", 2.0)
	yield(self,"speech_complete")
	change_state(STATES.QUESTION)

func start_validation():
	say("Let's see everybodies answers...",2.0)
	yield(get_tree().create_timer(1.0), "timeout")
	player.show_player_answer(given_answer)
	for i in [1,2,3,4]:
		actors[i].show_answer(current_question)
	yield(self,"speech_complete")
	Sounds.play("drumroll")
	say("And the correct answer is...", 4.0)
	yield(self,"speech_complete")
	say(str(int(data.answers[active_category][current_question][4])+1) +" !!")
	yield(self,"speech_complete")

	if validate(given_answer):
		say("You are correct!")
		yield(self,"speech_complete")
		Sounds.play("applause1")
		question_anim.play("SlideOut")
		current_question+=1
		yield(question_anim,"animation_finished")
		reset_answers()
		if is_everyone_dead():
			say("Let's continue with the next question")
		else:
			if will_some_die():
				say("That can't be said about everyone...")
			else:
				say("Everyone got this one right! What a surprise!")

			yield(self,"speech_complete")
			check_candidates()
			yield(get_tree().create_timer(0.4),"timeout")
			Sounds.play("ohmygod")
			say("RIP\nBut let's continue with the next question'")
		yield(self,"speech_complete")
		change_state(STATES.QUESTION)
	else:
		start_gameover()

func start_gameover():
	user_data.set_cat_score(active_category, current_question)
	WebHandler.upload_answers(active_category, answers_given[active_category])
	gameover_label.text = create_gameover_text()
	say("Oh no! Your answer was wrong.\nYou know the deal...\nNo second Chances!\nBut thanks for participating!")
	yield(self,"speech_complete")
	check_candidates()
	question_anim.play("Fall")
	yield(get_tree().create_timer(1.0),"timeout")
	player.anims.play("Smash")
	yield(get_tree().create_timer(0.5),"timeout")
	Sounds.play("ohmygod")
	yield(get_tree().create_timer(2.0),"timeout")
	say("Goodbye and until next time!")
	candidates_wave()

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
	for category in ["gaming","godot","surprise"]:
		print("loaded category score: " + category)
		print(user_data.category_score)
		print(user_data.category_score[category])
		if user_data.category_score[category] != -1:
			print(user_data.category_score[category])
			print("closing")
			cat2button[category].disabled=true
			cat2button[category].text = "%s %s / 10" % [category.capitalize(), str(user_data.category_score[category])]

		else:
			if user_data.player_name == "":
				cat2button[category].disabled=true
			else:
				cat2button[category].disabled=false
			cat2button[category].text = category.capitalize()

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


func will_some_die():
	var will_die = false
	for i in [1,2,3,4]:
		if actors[i].alive:
			if int(actors[i].answer_list[current_question]) != data.answers[active_category][current_question][4]:
				will_die = true
	return will_die

func check_candidates():
	for i in [1,2,3,4]:
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
	$TitleLayer/Title.hide()
	change_state(STATES.MENU)
	transition.play("FadeIn")

func on_connection_ok():
	$TitleLayer/Title/ConnectionPanel/Label.text = "Loading Lobbies..."
	$TitleLayer/Title/ConnectionPanel/ConnectButton.hide()

func on_lobbies_loaded():
	$TitleLayer/Title/ConnectionPanel/Label.text = "Ready to play!"

func on_connection_failed():
	$TitleLayer/Title/ConnectionPanel/Label.text = "Connection failed :( Check your firewall settings"
	$TitleLayer/Title/ConnectionPanel/ConnectButton.show()

func _on_ConnectButton_pressed():
	WebHandler.test_connection()
