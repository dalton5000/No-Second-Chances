extends Node2D


var head_frame = 0 setget set_head_frame
var body_frame = 0 setget set_body_frame
var leg_frame = 0
var arm_frame = 0

var body_frame_offset = 16
var leg_frame_offset = 480
var arm_frame_offset = 768

var body_map = [0,1,2,3,4,5,6,7,8,10,12,14,16,18,20,22]
var arm_map = [0,2,4,8,4,2,8,0,4,2,8,0,10,10,10,10,10,10,10,10,0,0,0,0,0,0,0]
var leg_map = [0,3,1,2,1,1,1,0,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0]
var uni_bodies = [0,1,2,3,4,5,6,7]

var dark = false setget set_dark

func _ready():
	pass
#	$Body/Head/Sprite.frame = head_frame
#	$Body/Sprite.frame = body_frame + int(dark)

func set_head_frame(f):
	head_frame = f
	if head_frame % 2 == 1:
		dark = true
	else:
		dark = false
	$Body/Head/Sprite.frame = head_frame
	set_body_frame(body_frame)
	print("head frame %s, is dark: %s" %[ str(head_frame), str(dark)])

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

	print("head: %s, body: %s, arm: %s, leg: : %s" % [str(head_frame), str(body_frame), str(leg_map[body_frame]), str( arm_map[body_frame] ) ] )


func set_dark(d):
	dark = d
	set_body_frame(body_frame)

func fall():
	$BaseAnimations.play("Fall")
