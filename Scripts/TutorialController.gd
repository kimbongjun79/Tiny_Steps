# TutorialController.gd   (Godot 4.x)
extends Node
signal step1_dropped(texture: Texture2D)

# ───────── 튜토리얼 단계별 메시지 ─────────
const INTRO := [
	"안녕하세요! 예비 부모님,\n튜토리얼에 오신 것을 환영합니다.",
	"이 게임의 목표는 아이 주변 안전사고를\n미리 예방하는 것입니다.",
	"준비되셨으면 아래 버튼을 눌러 시작하세요."
]
const DROP_HINT := ["하단에서 모바일을 드래그하여\n아이 요람에 걸어보세요."]
const ENDING   := ["튜토리얼이 끝났습니다!\n축하드립니다."]

enum { INTRO_PHASE, HINT_PHASE, PLAY_PHASE, END_PHASE }
var phase    : int   = INTRO_PHASE
var messages : Array = []
var idx      : int   = 0

@export var typing_speed : float     = 0.05   # 글자 출력 간격
@export var mobile_scale : float     = 0.25    # 드롭된 모빌 배율
@export var baby_reach_texture : Texture2D    # 손 뻗는 아기 이미지

# ───────── 노드 참조 ─────────
@onready var txt         : Label             = $UIPanel/TextBox
@onready var btn         : Button            = $UIPanel/NextButton
@onready var beep        : AudioStreamPlayer2D = $UIPanel/TypeSound
@onready var sfx_drop    : AudioStreamPlayer2D = $UIPanel/DropSFX
@onready var baby        : Sprite2D          = $Background/BabySprite
@onready var attach      : Sprite2D          = $Background/MobileAttach
@onready var menu        : Control           = $MobileMenuPanel
@onready var panel       : Control           = $UIPanel
@onready var fx_particle : GPUParticles2D    = $CradleDropZone/FX

# ───────── 초기화 ─────────
func _ready() -> void:
	btn.pressed.connect(_on_next)
	connect("step1_dropped", _on_drop_done)
	_enter_intro()

# ───────── 단계 진입 함수들 ─────────
func _enter_intro():
	phase = INTRO_PHASE
	messages = INTRO.duplicate(); idx = 0
	menu.visible = false; attach.visible = false
	btn.text = "다음"; btn.disabled = true
	_show()

func _enter_hint():
	phase = HINT_PHASE
	messages = DROP_HINT; idx = 0
	panel.visible = true; menu.visible = false
	btn.text = "다음"; btn.disabled = true
	_show()

func _enter_play():
	phase = PLAY_PHASE
	panel.visible = false; menu.visible = true
	btn.disabled = true    # 드롭 전까지 비활성

func _enter_end():
	phase = END_PHASE
	messages = ENDING; idx = 0
	panel.visible = true; menu.visible = false
	btn.text = "확인"; btn.disabled = true
	_show()

# ───────── 메시지 출력 & 타이핑 ─────────
func _show():
	btn.disabled = true          # 출력 전 무조건 잠금
	txt.text = ""
	_type(messages[idx])

func _type(line:String) -> void:
	for ch in line:
		txt.text += ch; beep.play()
		await get_tree().create_timer(typing_speed).timeout
	btn.disabled = false         # 타이핑 끝나면 활성화

# ───────── Next/Confirm 클릭 ─────────
func _on_next() -> void:
	match phase:
		INTRO_PHASE:
			idx += 1
			if idx < messages.size(): _show()
			else: _enter_hint()
		HINT_PHASE:
			_enter_play()
		END_PHASE:
			get_tree().change_scene("res://Scenes/NextScene.tscn")

# ───────── 드롭 성공 처리 ─────────
func _on_drop_done(tex: Texture2D) -> void:
	attach.texture = tex
	attach.scale   = Vector2.ONE * mobile_scale
	attach.visible = true
	if baby_reach_texture: baby.texture = baby_reach_texture
	sfx_drop.play()
	fx_particle.restart()
	_enter_end()
	btn.disabled = false
