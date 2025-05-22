# TutorialController.gd
extends Node
signal step1_dropped(texture: Texture2D)

# ——— 튜토리얼 메시지 리스트 ———
var messages: Array[String] = [
	"안녕하세요! 예비 부모님,\n튜토리얼에 오신 것을 환영합니다.",
	"이 게임의 목표는 아이 주변 안전사고를\n미리 예방하는 것입니다.",
	"준비되셨으면 아래 버튼을 눌러 시작하세요."
]

# 단계(0=설명, 1=드롭, 2=완료) 및 메시지 인덱스
var step: int = 0
var msg_index: int = 0

# 타이핑 속도(초)
@export var typing_speed: float = 0.05

# ——— 노드 레퍼런스 ———
@onready var text_box      : Label               = $UIPanel/TextBox
@onready var next_button   : Button              = $UIPanel/NextButton
@onready var type_sound    : AudioStreamPlayer2D = $UIPanel/TypeSound
@onready var mobile_menu   : Control             = $MobileMenuPanel
@onready var mobile_attach : Sprite2D            = $Background/MobileAttach

func _ready() -> void:
	mobile_attach.visible = false
	mobile_menu.visible   = false
	next_button.text      = "다음"
	next_button.disabled  = true
	next_button.pressed.connect(Callable(self, "_on_next_pressed"))
	self.connect("step1_dropped", Callable(self, "_on_step1_dropped"))
	_show_current_message()

# ——— 1) 메시지 출력 준비 ———
func _show_current_message() -> void:
	text_box.text        = ""
	next_button.disabled = true
	# 코루틴처럼 _type_message 실행
	_type_message(messages[msg_index])

# ——— 2) 한 글자씩 타이핑 (async 키워드 없이) ———
func _type_message(msg: String) -> void:
	for ch in msg:
		text_box.text += ch
		type_sound.play()
		# await 사용만으로도 일시정지 가능
		await get_tree().create_timer(typing_speed).timeout

	# 타이핑 끝나면 버튼 활성화
	next_button.disabled = false
	if step >= 2 and msg_index == messages.size() - 1:
		next_button.text = "확인"

# ——— 3) Next/Confirm 버튼 클릭 ———
func _on_next_pressed() -> void:
	match step:
		0:
			msg_index += 1
			if msg_index < messages.size():
				_show_current_message()
			else:
				# 설명 끝 → 드롭 단계 준비
				step      = 1
				messages  = ["하단에서 모바일을 드래그하여\n아이 요람에 걸어보세요."]
				msg_index = 0
				mobile_menu.visible = true
				_show_current_message()

		1:
			# 드롭 후 완료 메시지
			step      = 2
			mobile_menu.visible = false
			messages  = ["튜토리얼이 끝났습니다!\n축하드립니다."]
			msg_index = 0
			_show_current_message()

		2:
			# 최종 확인 → 씬 전환
			get_tree().change_scene("res://Scenes/NextScene.tscn")

# ——— 4) 모바일 드랍 시그널 처리 ———
func _on_step1_dropped(texture: Texture2D) -> void:
	mobile_attach.texture = texture
	mobile_attach.visible = true
	next_button.disabled  = false


func _on_next_button_pressed() -> void:
	pass # Replace with function body.
