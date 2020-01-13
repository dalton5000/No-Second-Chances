extends Control

const HEAD_MAX = 13
const BODY_MAX = 15

var head_val = 0
var body_val = 0

var value_string = "%s/%s"

onready var head_value_label = $VBoxContainer/HeadRow/ValueLabel
onready var body_value_label = $VBoxContainer/BodyRow/ValueLabel

onready var actor = $VBoxContainer/ActorPanel/Control/Actor

func _ready():
	$VBoxContainer/BodyRow/ButtonLeft.connect("pressed", self, "body_pressed", [-1])
	$VBoxContainer/BodyRow/ButtonRight.connect("pressed", self, "body_pressed", [1])
	$VBoxContainer/HeadRow/ButtonLeft.connect("pressed", self, "head_pressed", [-1])
	$VBoxContainer/HeadRow/ButtonRight.connect("pressed", self, "head_pressed", [1])

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
	body_value_label.text = value_string % [str(body_val), str(13)]

func head_pressed(val):
	if head_val+val > HEAD_MAX:
		head_val = 0
	elif head_val+val < 0:
		head_val = HEAD_MAX
	else:
		head_val += val

	print(val)
	print(head_val)
	actor.head_frame = head_val
	head_value_label.text = value_string % [str(head_val), str(15)]
