extends Node2D

var total_shots = 0
var success_shots = 0

@onready var intro_label = $UI/IntroLabel
@onready var baby = $BabyImg
@onready var phone = $hand
@onready var label = $UI/Label
@onready var countdown_label = $UI/CountdownLabel
@onready var result_button = $UI/resultButton
@onready var next_button = $UI/nextButton
@onready var explain_label = $UI/explainLabel

# Sound
@onready var background_sound = $backgroundSound_bird
@onready var countdown_sound = $CountdownSound_Bip
@onready var camera_sound = $photoSound
@onready var photo_fail = $photo_Failure
@onready var photo_success = $photo_success
@onready var childlaugh_sound = $childlaughSound
@onready var nextbutton_sound = $nextbuttonSound

var speed = 250
var game_started = false
var countdown_started = false
var countdown_ended = false  # 카운트다운 끝난 후 true

func _ready():
	
	background_sound.play()
	$UI/resultButton.pressed.connect(_on_result_button_pressed)
	$UI/nextButton.pressed.connect(_on_next_button_pressed)
	label.text = "아이가 핸드폰 안에 들어왔을 때 찍어주세요!"
	countdown_label.visible = false
	result_button.visible = false
	label.visible = false
	next_button.visible = false
	explain_label.visible = false

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if not game_started and not countdown_started:
			countdown_started = true
			intro_label.visible = false
			result_button.visible = false
			start_countdown()

func start_countdown():
	countdown_label.visible = true
	for i in [3, 2, 1]:
		countdown_label.text = str(i)
		countdown_sound.play()
		await get_tree().create_timer(1).timeout
	countdown_label.visible = false
	game_started = true
	label.visible = true
	countdown_ended = true  # 사진 찍기 가능
	childlaugh_sound.play()

var direction = 1  # 오른쪽: 1, 왼쪽: -1

func _process(delta):
	if game_started:
		baby.position.x += speed * direction * delta
		
		# 오른쪽 끝 도달하면 방향 반전
		if baby.position.x > get_viewport_rect().size.x - 100:
			direction = -1
			baby.flip_h = true  # 좌우 반전

		# 왼쪽 끝 도달하면 방향 반전
		elif baby.position.x < 100:
			direction = 1
			baby.flip_h = false

# 핸드폰 hand와 아이 스프라이프가 겹치는 지 안 겹치는지 따지는 함수
func _is_baby_inside_phone() -> bool:
	var baby_rect = Rect2(
		baby.global_position - baby.texture.get_size() * baby.scale / 2,
		baby.texture.get_size() * baby.scale
	)
	var phone_rect = Rect2(
		phone.global_position - phone.texture.get_size() * phone.scale / 2,
		phone.texture.get_size() * phone.scale
	)
	return phone_rect.intersects(baby_rect)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if not countdown_ended:
			return  # 아직 카운트다운 안 끝났으면 클릭 무시

		if _is_baby_inside_phone():
			total_shots += 1
			success_shots += 1 # 성공 횟수 증가
			camera_sound.play()
			photo_success.play()
			label.text = "사진이 찍혔습니다! 🎉"
			result_button.visible = true
		else:
			total_shots += 1
			camera_sound.play()
			photo_fail.play()
			label.text = "실패! 다시 찍어보세요."
			


func _on_result_button_pressed() -> void:
	next_button.visible = true
	explain_label.visible = true
	explain_label.text = "총 사진 수: %d회\n성공한 사진 수: %d회" % [total_shots, success_shots]


func _on_next_button_pressed() -> void:
	nextbutton_sound.play()
	get_tree().change_scene_to_file("res://Scenes/step_2_explain.tscn")

	
