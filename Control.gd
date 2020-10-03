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
onready var mMusic = $AudioStreamPlayer
onready var mAlerteRouge = $alerteRouge

var notstartedyet=true
var mState = 0

var error_pal = 0
export(int) var pallonier_amp = 150
export(int) var pallonier_user_amp = 180
export(int) var seuil_pallonier = 35
export(int) var alarm_pallonier = 45
var pallonier_start_x = 214
var pallonier_f = 0.0
var diff = 0.0
func update_pallonier(delta):
	mTargetPallonier.rect_position.x = pallonier_start_x + pallonier_amp*sin(pallonier_f)
	pallonier_f += 0.5*delta

	var right = Input.get_action_strength("pal_right") - Input.get_action_strength("pal_left")
	diff = lerp(diff, right, 0.03) # 0.01 is too easy
	mPallonier.position.x = pallonier_start_x + diff*pallonier_user_amp
	
	if not notstartedyet:
		var epal = mPallonier.position.x - mTargetPallonier.rect_position.x
		if abs(epal) > seuil_pallonier:
			error_pal += delta
		if abs(epal) > alarm_pallonier:
			bipper = true

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

var bipper = false
func _process(delta):
	bipper = false
	update_pallonier(delta)
	if mState >= 1:
		update_cursor(delta)

	if not notstartedyet:
		if bipper:
			mMusic.play()
			mAlerteRouge.visible = true
		else:
			mAlerteRouge.visible = false

# if Input.get_connected_joypads().size() > 0:
export(int) var cursor_user_amp = 3
export(int) var cursor_amp = 70
export(int) var cursorseuil = 37
var cursor_start_x = 525
var cursor_start_y = 175
var cursor_f = 0.0
var cursor_speed = Vector2(0, 0)
var error_cursor = 0.0
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
	cursor_speed.x = lerp(cursor_speed.x, rightleft, 0.05)
	cursor_speed.y = lerp(cursor_speed.y, updown, 0.05)
	mCursor.position += cursor_user_amp*cursor_speed
	
	mCursor.position.x = lerp(mCursor.position.x, cursor_start_x, 0.02)
	mCursor.position.y = lerp(mCursor.position.y, cursor_start_y, 0.02)
	
	if not notstartedyet:
		var dist = mCursor.position.distance_to(mTargetCursor.position)
		if dist > cursorseuil:
			error_cursor += delta
			bipper = true 

var sum = 0
var oldnum = 0
func _on_Timer_timeout():
	if mState == 2:
		notstartedyet = false
		var num = randi()%8 + 1
		if num == oldnum:
			if num == 1:
				num = 2
			else:
				num -= 1
		sum += num
		mRandNum.text = str(num)
		oldnum = num
	
	if sum >= 50:
		print("Solution (somme): ", sum)
		print("Erreur pallonier: ", error_pal)
		print("Erreur curseur: ", error_cursor)
		print("Erreur total: ", error_pal+error_cursor)
		get_tree().quit()

func _ready():
	randomize()
	update_hided()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		mState += 1
		update_hided()
