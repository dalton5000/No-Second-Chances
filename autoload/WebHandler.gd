extends Node

signal connection_established
signal lobbies_loaded
signal connection_failed

var answer_url = "http://dalton5000.pythonanywhere.com/add_answers"
var lobbies = {}
var connection_ok = false

func get_lobbies():
	for category in ["gaming", "godot", "surprise"]:
		lobbies[category] = ""

func _ready():
	test_connection()

func test_connection():
	$ConnectionTest.request("http://dalton5000.pythonanywhere.com/ping")

func _on_LobbyRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	lobbies = json.result["lobbies"]
	emit_signal("lobbies_loaded")
#	print("lobbies loaded")
#	print (lobbies)

#func _physics_process(delta):
#	if Input.is_action_just_pressed("ui_down"):
#		$ConnectionTest.request("http://dalton5000.pythonanywhere.com/ping")

func upload_answers(category : String, answers : Array):
	var dict = {}
	dict["key"] = "dlt5k"
	dict["name"] = user_data.player_name
	dict["body"] = user_data.body
	dict["head"] = user_data.head
	dict["category"] = category
	while answers.size() < 10:
		answers.append(0)
	dict["answers"] = answers

	var QUERY = to_json(dict)
	var HEADERS = ["User-Agent: Jeff", "Content-Type: application/json"]
	var RESPONSE = $AnswerUpload.request(answer_url,HEADERS, true, HTTPClient.METHOD_POST,  QUERY)
	print("uploading")
	print(QUERY)

func _on_ConnectionTest_request_completed(result, response_code, headers, body):
	if result == 0:
		connection_ok = true
		emit_signal("connection_established")
		print("connection ok")
		$LobbyRequest.request("http://dalton5000.pythonanywhere.com/get_lobbies")
	else:
		emit_signal("connection_established")
		print("connection ok")
