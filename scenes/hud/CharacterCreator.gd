extends Control

signal finished

const HEAD_MAX = 13
const BODY_MAX = 16

var head_val = 0
var body_val = 0

var value_string = "%s/%s"

onready var head_value_label = $P/VBoxContainer/HeadRow/ValueLabel
onready var body_value_label = $P/VBoxContainer/BodyRow/ValueLabel

onready var actor = $P/VBoxContainer/ActorPanel/Control/Actor

func _ready():
	$P/VBoxContainer/BodyRow/ButtonLeft.connect("pressed", self, "body_pressed", [-1])
	$P/VBoxContainer/BodyRow/ButtonRight.connect("pressed", self, "body_pressed", [1])
	$P/VBoxContainer/HeadRow/ButtonLeft.connect("pressed", self, "head_pressed", [-1])
	$P/VBoxContainer/HeadRow/ButtonRight.connect("pressed", self, "head_pressed", [1])

	body_value_label.text = value_string % [str(body_val), str(BODY_MAX)]
	head_value_label.text = value_string % [str(head_val), str(HEAD_MAX)]

func body_pressed(val):
	if body_val+val > BODY_MAX:
		body_val = 0
	elif body_val+val < 0:
		body_val = BODY_MAX
	else:
		body_val += val

	actor.body_frame = body_val
	body_value_label.text = value_string % [str(body_val), str(16)]

func head_pressed(val):
	if head_val+val > HEAD_MAX:
		head_val = 0
	elif head_val+val < 0:
		head_val = HEAD_MAX
	else:
		head_val += val

	actor.head_frame = head_val
	head_value_label.text = value_string % [str(head_val), str(13)]

func clean(string):
	string = string.replace("Penis", "Funny")
	string = string.replace("penis", "Funny")
	string = string.replace("-", "")
	return(string)


func _on_Button_pressed():
	user_data.player_name = clean($P/VBoxContainer/NameRow/LineEdit.text)
	user_data.head = head_val
	user_data.body = body_val
	user_data.save_config()
	emit_signal("finished")
