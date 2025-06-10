# TutorialController.gd  – Godot 4.x
# ===============================================================
# 영유아 안전사고 튜토리얼 (모빌 → 분유 → 트림)
# ---------------------------------------------------------------
# 단계(enum)
#   0  INTRO         인삿말 3줄
#   1  MOBILE_HINT   “모빌 달아보세요!”
#   2  MOBILE_PLAY   모빌 드래그·드롭
#   3  MILK_PRAISE   “잘하셨습니다.”   ← 칭찬
#   4  MILK_HINT     칭얼 + 울기직전  ← 분유 안내
#   5  MILK_PLAY     분유 드래그·드롭 (온도 판정)
#   6  BURP_HINT     “트림을 도와주세요!”
#   7  BURP_PLAY     올바른 자세(안고 두드리기) 드래그·드롭
#   8  END           완료
# ---------------------------------------------------------------

extends Node
signal drag_completed(item_data : Dictionary)         # {texture, scale, meta}

# ───── enum & 텍스트 상수 ────────────────────────────────────
enum Phase { INTRO, MOBILE_HINT, MOBILE_PLAY,
			 MILK_PRAISE, MILK_HINT, MILK_PLAY,
			 BURP_HINT, BURP_PLAY,
			 END }

const CORRECT_MILK_TYPE := "warm"      # 분유 정답(적온)

const INTRO_MSGS      = [
	"안녕하세요! 예비 부모님,\nTiny Step에 오신 것을 환영합니다.",
	"이 게임에서는 아이를 키우기 앞서\n아이를 키울때 필요한 지식을 알려줄것입니다.",
	"준비되셨으면 아래 버튼을 눌러 시작하세요."
]
const MOBILE_HINT_MSG = ["우선 연습입니다.\n천장에 원하는 모빌을 달아보세요!"]
const MILK_PRAISE_MSG = ["잘하셨습니다!"]                          # 칭찬
const MILK_HINT_MSG   = [
	"아이가 칭얼대기 시작했어요.\n신생아일때는 3시간 간격으로 조금씩 자주 먹여야해요.\n배고픈 것 같으니 올바른 분유를 준비해주세요!"
]
const BURP_HINT_MSG   = ["분유를 준비할때에는 70℃ 이상의 따뜻한 물에 분유를 녹여줘야해요.\n그리고 아이의 위는 연약해서 젖병을 먹일때에는 40℃정도로 식힌 뒤 흔들어줘야해요.\n이제 아기를 안아 등을 두드려 트림을 도와주세요."]
const END_MSGS        = ["젖병을 빨 때 아기는 공기를 함께 삼키는데\n위 속에 남은 공기가 빠져나오지 않으면 속이 더부룩해지고 불편함을 느껴요.\n등을 두드려 트림을 나오게 하면 위‧장에 쌓인 가스를 줄여 복통과 배앓이를 예방할 수 있습니다.\n수고하셨습니다."]

# ───── Inspector 노출 변수 ──────────────────────────────────
@export var typing_speed      : float = 0.05          # 한 글자당 타이핑 시간
@export var attach_scale      : float = 0.7           # 모빌 부착 배율
@export var milk_attach_scale : float = 0.35          # 분유통 부착 배율
# 아기 표정(5종)
@export var baby_default_tex      : Texture2D         # 기본 웃음
@export var baby_sleep_tex        : Texture2D         # 잠자는(시작)
@export var baby_almost_cry_tex   : Texture2D         # 울기 직전
@export var baby_cry_tex          : Texture2D         # 찡그림(오답)
@export var baby_reach_tex        : Texture2D         # 손 뻗음(모빌)

# ───── 내부 상태 변수 ──────────────────────────────────────
var phase                : int   = Phase.INTRO
var _next_after_text      : int   = -1
var _next_after_drag      : int   = -1
var messages              : Array = []
var msg_index             : int   = 0
var mobile_attached       : bool  = false
var tween_ui              : Tween = null              # 메뉴 슬라이드 Tween

# ───── 노드(onready) 참조 ─────────────────────────────────
@onready var txt          : Label    = $UIPanel/TextBox
@onready var btn          : Button   = $UIPanel/NextButton
@onready var panel        : Control  = $UIPanel

# 메뉴 & 드롭 존
@onready var menu_mobile  : Control  = $MobileMenuPanel
@onready var menu_milk    : Control  = $MilkMenuPanel
@onready var menu_burp    : Control  = $BurpMenuPanel
@onready var drop_mobile  : Control  = $CradleDropZone
@onready var drop_milk    : Control  = $MilkDropZone
@onready var drop_burp    : Control  = $BurpDropZone

# 배경/캐릭터
@onready var baby         : Sprite2D = $Background/BabySprite
@onready var attach       : Sprite2D = $Background/MobileAttach      # 모빌
@onready var milk_attach  : Sprite2D = $Background/MilkAttach        # 분유통

# 효과음
@onready var beep         : AudioStreamPlayer2D = $UIPanel/TypeSound
@onready var sfx_drop     : AudioStreamPlayer2D = $UIPanel/DropSFX
@onready var sfx_wrong    : AudioStreamPlayer2D = $UIPanel/WrongSFX
@onready var fx_particle  : GPUParticles2D       = $CradleDropZone/FX

# ───── 초기화(_ready) ─────────────────────────────────────
func _ready() -> void:
	btn.pressed.connect(_on_next)
	connect("drag_completed", Callable(self, "_on_drag_completed"))
	baby.texture      = baby_sleep_tex
	milk_attach.visible = false                     # 분유통 숨김
	_init_menus_position()
	_enter_intro()

# (하단 메뉴 초기 위치 = 화면 아래, 비가시)
func _init_menus_position() -> void:
	var base_y   : float = panel.global_position.y
	var hidden_y : float = base_y + menu_mobile.size.y
	for m in [menu_mobile, menu_milk, menu_burp]:
		m.global_position.y = hidden_y
		m.visible = false

# ───── 단계 진입 래퍼 함수 ────────────────────────────────
func _enter_intro():        _enter_text_phase(INTRO_MSGS,  Phase.INTRO,       Phase.MOBILE_HINT)
func _enter_mobile_hint():  _enter_text_phase(MOBILE_HINT_MSG, Phase.MOBILE_HINT, Phase.MOBILE_PLAY)
func _enter_milk_praise():  _enter_text_phase(MILK_PRAISE_MSG, Phase.MILK_PRAISE, Phase.MILK_HINT)
func _enter_milk_hint():    _enter_text_phase(MILK_HINT_MSG,   Phase.MILK_HINT,   Phase.MILK_PLAY)
func _enter_burp_hint():    _enter_text_phase(BURP_HINT_MSG,   Phase.BURP_HINT,   Phase.BURP_PLAY)
func _enter_end():          _enter_text_phase(END_MSGS,        Phase.END,        -1)

func _enter_mobile_play():  _enter_drag_phase(Phase.MOBILE_PLAY, menu_mobile, drop_mobile, Phase.MILK_PRAISE)
func _enter_milk_play():    _enter_drag_phase(Phase.MILK_PLAY,   menu_milk,  drop_milk,  Phase.BURP_HINT)
func _enter_burp_play():    _enter_drag_phase(Phase.BURP_PLAY,   menu_burp,  drop_burp,  Phase.END)

# ───── 공통: 텍스트 단계 진입 ─────────────────────────────
func _enter_text_phase(msgs:Array, cur:int, nxt:int) -> void:
	phase = cur
	_next_after_text = nxt
	messages = msgs.duplicate()
	msg_index = 0
	_show_panel(true)
	attach.visible = mobile_attached or (cur == Phase.END)
	btn.text = "확인" if nxt == -1 else "다음"
	btn.disabled = true
	_show_current_message()

# ───── 공통: 드래그 단계 진입 ─────────────────────────────
func _enter_drag_phase(cur:int, menu:Control, zone:Control, nxt_text:int) -> void:
	phase = cur
	_next_after_drag = nxt_text
	_show_panel(false)
	_slide_menu(menu, true)
	btn.disabled = true
	# DropZone 스크립트에서 drag_completed emit

# ───── UIPanel & 메뉴 표시/숨김 ──────────────────────────
func _show_panel(show:bool) -> void:
	if show:
		_slide_menu(menu_mobile, false)
		_slide_menu(menu_milk,   false)
		_slide_menu(menu_burp,   false)
	panel.visible = show

func _slide_menu(menu:Control, show:bool) -> void:
	if menu.visible == show: return
	var base_y : float = panel.global_position.y
	var hidden_y : float = base_y + menu.size.y
	var from_y : float = hidden_y if show else base_y
	var to_y   : float = base_y   if show else hidden_y
	if show:
		menu.global_position.y = from_y
		menu.visible = true
	if tween_ui and tween_ui.is_running(): tween_ui.kill()
	tween_ui = create_tween()
	tween_ui.tween_property(menu, "global_position:y", to_y, 0.25)\
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)\
			.finished.connect(Callable(self, "_on_menu_tween_finished").bind(menu, show))

func _on_menu_tween_finished(menu:Control, show:bool) -> void:
	if not show: menu.visible = false

# ───── 텍스트 타이핑 출력 ────────────────────────────────
func _show_current_message():
	txt.text = ""; btn.disabled = true
	_type_text(messages[msg_index])

func _type_text(line:String) -> void:
	for ch in line:
		txt.text += ch
		beep.play()
		await get_tree().create_timer(typing_speed).timeout
	btn.disabled = false

# ───── Next / Confirm 버튼 ──────────────────────────────
func _on_next() -> void:
	# 같은 세트 안에서 다음 줄
	if msg_index + 1 < messages.size():
		msg_index += 1
		_show_current_message()
		return
	# 세트 끝 → 다음 단계
	match _next_after_text:
		Phase.MOBILE_HINT:  _enter_mobile_hint()
		Phase.MOBILE_PLAY:  _enter_mobile_play()
		Phase.MILK_PRAISE:  _enter_milk_praise()
		Phase.MILK_HINT:
			baby.texture = baby_almost_cry_tex      # 울기 직전 표정
			_enter_milk_hint()
		Phase.MILK_PLAY:   _enter_milk_play()
		Phase.BURP_HINT:   _enter_burp_hint()
		Phase.BURP_PLAY:   _enter_burp_play()
		Phase.END:         _enter_end()
		-1: get_tree().change_scene_to_file("res://Scenes/StageSelect.tscn")

# ───── 드래그 완료 처리 (DropZone → emit) ───────────────
func _on_drag_completed(data:Dictionary) -> void:
	var tex   : Texture2D = data.texture
	var scale : float     = data.scale
	var meta  : Dictionary = data.get("meta", {})

	# ── A. 모빌 단계 성공
	if phase == Phase.MOBILE_PLAY:
		attach.texture = tex
		attach.scale   = Vector2.ONE * scale
		attach.visible = true
		mobile_attached = true
		baby.texture   = baby_reach_tex
		sfx_drop.play();
		_enter_milk_praise()
		return

	# ── B. 분유 단계
	if phase == Phase.MILK_PLAY:
		milk_attach.texture = tex
		milk_attach.scale   = Vector2.ONE * milk_attach_scale
		milk_attach.visible = true
		if meta.get("type") == CORRECT_MILK_TYPE:
			baby.texture = baby_default_tex
			sfx_drop.play();
			_enter_burp_hint()
		else:
			baby.texture = baby_cry_tex
			sfx_wrong.play()
			_enter_text_phase(
				["앗! 온도가 맞지 않아요.\n적당한 분유를 다시 시도해 보세요."],
				Phase.MILK_HINT, Phase.MILK_PLAY
			)
		return

	# ── C. 트림 단계
	if phase == Phase.BURP_PLAY:
		baby.texture = tex                                 # 선택한 자세 이미지
		var good : bool = meta.get("type", "bad") == "good"
		if good:
			sfx_drop.play()
			_enter_end()
		else:
			sfx_wrong.play()
			_enter_text_phase(
				["아이의 소화 돕는 올바른 자세가 아니에요.\n아기를 안아 등을 두드려 주세요!"],
				Phase.BURP_HINT, Phase.BURP_PLAY
			)
