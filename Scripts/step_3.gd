extends Node2D

@onready var child_sprite = $child
# 아이 이미지들
var image_necklace = preload("res://Assets/hideinfo_child/child_necklace.png")
var image_inner = preload("res://Assets/hideinfo_child/child_inner.png")
var image_insole = preload("res://Assets/hideinfo_child/child_insole.png")
var image_wrist = preload("res://Assets/hideinfo_child/child_wrist.png")


@onready var label = $Label
@onready var questionlabel = $questionLabel
@onready var explainlabel = $explainLabel

@onready var choosebutton1 = $HBoxContainer/Option1
@onready var choosebutton2 = $HBoxContainer/Option2
@onready var choosebutton3 = $HBoxContainer/Option3
@onready var choosebutton4 = $HBoxContainer/Option4

@onready var necklace = $Necklace
@onready var wristband = $Wristband
@onready var note = $Note
@onready var insole = $InsoleNote2

# UI
@onready var contact_input = $UI/LineEdit
@onready var address_input = $UI/LineEdit2
@onready var engrave_button = $UI/Button
@onready var warning_label = $UI/WarningLabel

# 새겨질 텍스트
@onready var necklace_label = $Necklace/Label
@onready var wristband_label = $Wristband/Label

# Sound
@onready var rightSound = $rightAnswerSound
@onready var wronganswer_Sound = $wrongAnswerSound

@onready var nextbutton = $nextButton

var selected = null
var game_started = false

func _ready():
	_hide_all()
	engrave_button.pressed.connect(_on_engrave_pressed)
	nextbutton.pressed.connect(_on_next_button_pressed)
	nextbutton.visible = false

func _hide_all():
	label.visible = true
	questionlabel.visible = false
	explainlabel.visible = false
	
	choosebutton1.visible = false
	choosebutton2.visible = false
	choosebutton3.visible = false
	choosebutton4.visible = false
	
	contact_input.visible = false
	address_input.visible = false
	engrave_button.visible = false
	warning_label.visible = false
	
	necklace.visible = false
	wristband.visible = false
	note.visible = false
	insole.visible = false
	
	necklace_label.visible = false
	wristband_label.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if not game_started:
			game_started = true
			label.visible = false
			questionlabel.visible = true

			# 버튼과 입력창 보이기
			choosebutton1.visible = true
			choosebutton2.visible = true
			choosebutton3.visible = true
			choosebutton4.visible = true
			
			contact_input.visible = true
			address_input.visible = true
			engrave_button.visible = true

func _on_engrave_pressed():
	var contact = contact_input.text.strip_edges()
	var address = address_input.text.strip_edges()

	if contact == "" or address == "":
		warning_label.text = "연락처와 주소를 모두 입력해주세요."
		warning_label.visible = true
		return

	warning_label.visible = false

	var info = "%s\n%s" % [contact, address]
	necklace_label.text = info
	wristband_label.text = info

	necklace_label.visible = true
	wristband_label.visible = true

func _update_selection(index):
	if selected != null:
		_clear_previous()

	selected = index
	match index:
		1:
			child_sprite.texture = image_necklace
			necklace.visible = true
			necklace_label.visible = true
			explainlabel.add_theme_color_override("font_color", Color8(52, 26, 18))
			explainlabel.text = "TIP.불특정 다수에게 정보가 가지 않도록\n 닫히는 목걸이가 필요해요"
		2:
			child_sprite.texture = image_inner
			note.visible = true
			explainlabel.add_theme_color_override("font_color", Color8(255, 0, 0))  # 빨간색
			explainlabel.text = "명찰은 낯선 사람에게 정보가 노출돼요.\n 안주머니에 넣어두는 것이 좋아요"
		3:
			child_sprite.texture = image_insole
			insole.visible = true
			explainlabel.add_theme_color_override("font_color", Color8(52, 26, 18))
			explainlabel.text = "TIP.낯선 사람의 접근과 유괴의 소지가 있어요\n 겉으로 노출되지 않는 곳에 넣어요"
		4:
			child_sprite.texture = image_wrist
			wristband.visible = true
			wristband_label.visible = true
			explainlabel.add_theme_color_override("font_color", Color8(52, 26, 18))
			explainlabel.text = "TIP.정보가 보이지 않도록\n 팔찌 안쪽에 새겨요"

	explainlabel.visible = true

func _clear_previous():
	necklace.visible = false
	wristband.visible = false
	note.visible = false
	insole.visible = false

func _on_option_1_pressed(): 
	_update_selection(1)
	nextbutton.visible = true
	rightSound.play()
	
func _on_option_2_pressed(): 
	_update_selection(2)
	wronganswer_Sound.play()
	
func _on_option_3_pressed(): 
	_update_selection(3)
	rightSound.play()
	nextbutton.visible = true
	
func _on_option_4_pressed(): 
	_update_selection(4)
	rightSound.play()
	nextbutton.visible = true


func _on_line_edit_text_submitted(new_text: String) -> void:
	pass # Replace with function body.


func _on_line_edit_2_text_submitted(new_text: String) -> void:
	pass # Replace with function body.
	
func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/step_4_fingerprint.tscn")
	_hide_all()
