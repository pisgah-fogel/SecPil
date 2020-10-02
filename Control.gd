extends Control

#TODO: Start with palonnier only
#TODO: Then the cursor (8), forward = up
#TODO: Then the number changing every 6 seconds, during 4 min (max sum = 50)

# TODO: move the 8 on the screen

onready var mRandNum = $RandNum

onready var mTargetPallonier = $targetPallonier
onready var mPallonier = $palonnier

onready var mTargetCursor = $targetCursor
onready var mCursor = $cursor

var mState = 0

export(int) var pallonier_amp = 150
export(int) var pallonier_user_amp = 180
var pallonier_start_x = 214
var pallonier_f = 0.0
var diff = 0.0
func update_pallonier(delta):
	mTargetPallonier.rect_position.x = pallonier_start_x + pallonier_amp*sin(pallonier_f)
	pallonier_f += 0.5*delta

	var right = Input.get_action_strength("pal_right")
	diff += 0.02*(right - 0.45)
	diff = lerp(diff, 0.0, 0.01)
	mPallonier.position.x = pallonier_start_x + diff*pallonier_user_amp

onready var mrectNum = $rectNum
onready var mrectPal = $rectPal
onready var mrecCursor = $rectCursor
func update_hided():
	if mState < 2:
		mrectNum.visible = false
		mRandNum.visible = false
	else:
		mrectNum.visible = true
		mRandNum.visible = true

	if mState < 1:
		mrecCursor.visible = false
		mCursor.visible = false
		mTargetCursor.visible = false
	else:
		mrecCursor.visible = true
		mCursor.visible = true
		mTargetCursor.visible = true

func _process(delta):
	update_pallonier(delta)
	if mState >= 1:
		update_cursor(delta)

# if Input.get_connected_joypads().size() > 0:
export(int) var cursor_user_amp = 90
export(int) var cursor_amp = 70
var cursor_start_x = 525
var cursor_start_y = 175
var cursor_f = 0.0
func update_cursor(delta):
	mTargetCursor.position.x = cursor_start_x + cursor_amp*sin(cursor_f)
	mTargetCursor.position.y = cursor_start_y + cursor_amp*cos(cursor_f)
	cursor_f += 0.5*delta
	
	var up = Input.get_action_strength("ui_up")
	var down = Input.get_action_strength("ui_down")
	var right = Input.get_action_strength("ui_right")
	var left = Input.get_action_strength("ui_left")
	
	var updown = down - up
	var rightleft = right - left
	var newcusorx = cursor_start_x + cursor_user_amp*(rightleft)
	var newcursory = cursor_start_y + cursor_user_amp*(updown)
	mCursor.position.x = lerp(mCursor.position.x, newcusorx, 0.05)
	mCursor.position.y = lerp(mCursor.position.y, newcursory, 0.05)

var sum = 0
var oldnum = 0
func _on_Timer_timeout():
	if mState == 2:
		var num = randi()%8 + 1
		if num == oldnum:
			num -= 1
		sum += num
		mRandNum.text = str(num)
		print("Sum: ", sum)
		oldnum = num

func _ready():
	randomize()
	update_hided()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		mState += 1
		update_hided()
