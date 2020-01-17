extends Node2D
class_name Actor

export var starts_high = false

var head_frame = 0 setget set_head_frame
var body_frame = 0 setget set_body_frame
var leg_frame = 0
var arm_frame = 0

var body_frame_offset = 16
var leg_frame_offset = 480
var arm_frame_offset = 768

var body_map = [0,1,2,3,4,5,6,7,8,10,12,14,16,18,20,22,24]
var arm_map = [0,2,4,8,4,0,8,2,4,2,8,0,10,10,10,0,4,10,10,10,0,0,0,0,0,0,0]
var leg_map = [0,3,1,2,1,0,1,1,4,4,4,4,4,4,4,0,1,1,0,0,0,0,0,0,0]
var uni_bodies = [0,1,2,3,4,5,6,7,15,16]

var player_name = "Anonymous" setget set_player_name
onready var name_label = $Body/NameLabel
onready var anims = $BaseAnimations

var answer_list = []

var dark = false setget set_dark
var score = 0
export var alive = true

func _ready():
	pass
	if starts_high:
		$Body.position.y = -1000
#	$Body/Head/Sprite.frame = head_frame
#	$Body/Sprite.frame = body_frame + int(dark)
func set_name_and_looks(n, b, h):
	set_body_frame(b)
	set_head_frame(h)
	set_player_name(n)

func read_from_string(string):
	var s = string.split(",")
	set_player_name(s[0])
	set_head_frame(int(s[1]))
	set_body_frame(int(s[2]))

func set_player_name(n):
	name_label.text = n
	player_name = n

func show_name(vis):
	name_label.visible = vis

func set_head_frame(f):
	head_frame = f
	if head_frame % 2 == 1:
		dark = true
	else:
		dark = false
	$Body/Head/Sprite.frame = head_frame
	set_body_frame(body_frame)

func set_body_frame(f):
	body_frame = f
	if body_frame in uni_bodies:
		$Body/Sprite.frame = body_map[f] + body_frame_offset
		$Body/LegLeft/Sprite.frame = leg_map[body_frame]+ leg_frame_offset
		$Body/LegRight/Sprite.frame = leg_map[body_frame]+ leg_frame_offset
	else:
		$Body/Sprite.frame = body_map[f] + body_frame_offset + int(dark)
		$Body/LegLeft/Sprite.frame = leg_map[body_frame] + int(dark) + leg_frame_offset
		$Body/LegRight/Sprite.frame = leg_map[body_frame] + int(dark) + leg_frame_offset
	$Body/ArmLeft/Sprite.frame = arm_map[body_frame] + int(dark) + arm_frame_offset
	$Body/ArmRight/Sprite.frame = arm_map[body_frame] + int(dark) + arm_frame_offset

func show_answer(idx):
	$Body/AnswerLabel.text = str(int(answer_list[idx])+1)
	$AnswerAnim.play("Reveal")

func show_player_answer(a):
	$Body/AnswerLabel.text = str(a+1)
	$AnswerAnim.play("Reveal")

func set_dark(d):
	dark = d
	set_body_frame(body_frame)

func fall():
	$BaseAnimations.play("Fall")
