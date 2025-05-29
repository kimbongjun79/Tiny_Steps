# TutorialController.gd   ― Godot 4.x
# -----------------------------------------------------------------
# 튜토리얼 단계(7단계)
#   0 INTRO         : 인삿말 3줄
#   1 MOBILE_HINT   : “모빌 달아보세요!” 1줄
#   2 MOBILE_PLAY   : 모빌 드래그·드롭 단계
#   3 MILK_PRAISE   : “잘하셨습니다.” 1줄   ← NEW
#   4 MILK_HINT     : “아이가 칭얼대기 …” 1줄 (울기 직전 얼굴)  ← NEW
#   5 MILK_PLAY     : 분유 드래그·드롭 단계 (온도 판정)
#   6 END           : 완료 1줄
# 드롭 결과
#   • 모빌  : Background/MobileAttach  (천장)
#   • 분유통: Background/MilkAttach    (탁자 위)  ← NEW
# -----------------------------------------------------------------

extends Node
signal drag_completed(item_data: Dictionary)     # 버튼 스크립트 → {texture, scale, meta}

# ─── 1. 단계 enum ───────────────────────────────────────────────
enum Phase { INTRO, MOBILE_HINT, MOBILE_PLAY,    # 0-2
			 MILK_PRAISE, MILK_HINT, MILK_PLAY,  # 3-5
			 END }                               # 6

# ─── 2. 출력 문구 상수 ──────────────────────────────────────────
const CORRECT_MILK_TYPE := "warm"       # 분유 온도 정답

const INTRO_MSGS = [
	"안녕하세요! 예비 부모님,\n튜토리얼에 오신 것을 환영합니다.",
	"이 게임의 목표는 아이 주변 안전사고를\n미리 예방하는 것입니다.",
	"준비되셨으면 아래 버튼을 눌러 시작하세요."
]
const MOBILE_HINT_MSG  = ["이제 천장에 모빌을 달아보세요!"]
const MILK_PRAISE_MSG  = ["잘하셨습니다."]    # 새 칭찬 단계
const MILK_HINT_MSG    = ["아이가 칭얼대기 시작했어요.\n마침 분유 먹인지 3시간이 지났네요.\n배고픈 것 같으니 분유를 준비해주세요!"]
const END_MSGS         = ["튜토리얼이 끝났습니다!\n축하드립니다."]

# ─── 3. Inspector에서 노출할 파라미터 ──────────────────────────
@export var typing_speed      : float = 0.05     # 텍스트 타이핑 속도(sec)
@export var attach_scale      : float = 0.7      # 모빌 천장 부착 배율
@export var milk_attach_scale : float = 0.35     # 탁자 분유 부착 배율  ← NEW

# 아기 표정 5종
@export var baby_default_tex  : Texture2D        # 기본 웃음
@export var baby_sleep_tex    : Texture2D        # 잠자는 (시작 상태)
@export var baby_almost_cry_tex : Texture2D      # 울기 직전  ← NEW
@export var baby_cry_tex      : Texture2D        # 찡그림 (오답)
@export var baby_reach_tex    : Texture2D        # 손 뻗는 (모빌 성공)

# ─── 4. 내부 상태 변수 ────────────────────────────────────────
var phase               : int   = Phase.INTRO    # 현재 단계
var _next_after_text    : int   = -1             # 텍스트 끝 후 갈 단계
var _next_after_drag    : int   = -1             # 드래그 끝 후 갈 단계
var messages            : Array = []             # 현재 출력 문구 배열
var msg_index           : int   = 0              # 현재 문구 인덱스
var mobile_attached     : bool  = false          # 모빌이 부착되었는가
var tween_ui            : Tween = null           # 메뉴 슬라이드용 Tween 객체

# ─── 5. 노드 참조 (onready) ───────────────────────────────────
@onready var txt          : Label   = $UIPanel/TextBox
@onready var btn          : Button  = $UIPanel/NextButton
@onready var panel        : Control = $UIPanel
@onready var menu_mobile  : Control = $MobileMenuPanel
@onready var menu_milk    : Control = $MilkMenuPanel
@onready var drop_mobile  : Control = $CradleDropZone
@onready var drop_milk    : Control = $MilkDropZone
@onready var baby         : Sprite2D = $Background/BabySprite
@onready var attach       : Sprite2D = $Background/MobileAttach
@onready var milk_attach  : Sprite2D = $Background/MilkAttach     # ← NEW
@onready var beep         : AudioStreamPlayer2D = $UIPanel/TypeSound
@onready var sfx_drop     : AudioStreamPlayer2D = $UIPanel/DropSFX
@onready var sfx_wrong    : AudioStreamPlayer2D = $UIPanel/WrongSFX
@onready var fx_particle  : GPUParticles2D      = $CradleDropZone/FX

# ─── 6. 초기 설정 (_ready) ───────────────────────────────────
func _ready() -> void:
	btn.pressed.connect(_on_next)                           # “다음” 버튼 클릭
	connect("drag_completed", Callable(self, "_on_drag_completed"))
	baby.texture     = baby_sleep_tex                       # 시작 표정 = 잠
	milk_attach.visible = false                             # 분유 아직 숨김
	_init_menus_position()                                  # 메뉴 최초 숨김
	_enter_intro()                                          # 인트로 단계 진입

# (화면 아래에 메뉴 두 개를 숨김 위치로 이동)
func _init_menus_position() -> void:
	var base_y   : float = panel.global_position.y
	var hidden_y : float = base_y + menu_mobile.size.y      # 패널보다 한 칸 아래
	for m in [menu_mobile, menu_milk]:
		m.global_position.y = hidden_y
		m.visible = false

# ─── 7. 단계 진입 래퍼 ─────────────────────────────────────────
# 텍스트 단계 4종
func _enter_intro():        _enter_text_phase(INTRO_MSGS,  Phase.INTRO,       Phase.MOBILE_HINT)
func _enter_mobile_hint():  _enter_text_phase(MOBILE_HINT_MSG, Phase.MOBILE_HINT, Phase.MOBILE_PLAY)
func _enter_milk_praise():  _enter_text_phase(MILK_PRAISE_MSG, Phase.MILK_PRAISE, Phase.MILK_HINT) # NEW
func _enter_milk_hint():    _enter_text_phase(MILK_HINT_MSG,   Phase.MILK_HINT,   Phase.MILK_PLAY)
func _enter_end():          _enter_text_phase(END_MSGS,        Phase.END,        -1)

# 드래그 단계 2종
func _enter_mobile_play():  _enter_drag_phase(Phase.MOBILE_PLAY, menu_mobile, drop_mobile, Phase.MILK_PRAISE)
func _enter_milk_play():    _enter_drag_phase(Phase.MILK_PLAY,   menu_milk,  drop_milk,  Phase.END)

# ─── 8. 공통 텍스트 단계 진입 ────────────────────────────────
func _enter_text_phase(msgs:Array, cur:int, nxt:int) -> void:
	phase = cur
	_next_after_text = nxt
	messages = msgs.duplicate()
	msg_index = 0

	_show_panel(true)                                       # UIPanel 보이기
	attach.visible = mobile_attached or (cur == Phase.END)  # 모빌 이미 부착?
	btn.text = "확인" if nxt == -1 else "다음"
	btn.disabled = true
	_show_current_message()

# ─── 9. 공통 드래그 단계 진입 ────────────────────────────────
func _enter_drag_phase(cur:int, menu:Control, zone:Control, nxt_text:int) -> void:
	phase = cur
	_next_after_drag = nxt_text

	_show_panel(false)             # UIPanel 숨김
	_slide_menu(menu, true)        # 메뉴 슬라이드 인
	btn.disabled = true

	# Godot 4 드래그 API: DropZone.gd 내부에서 emit_signal("drag_completed", data)

# ─── 10. UIPanel / 메뉴 슬라이드 표시 ─────────────────────────
func _show_panel(show: bool) -> void:
	if show:
		_slide_menu(menu_mobile, false)
		_slide_menu(menu_milk, false)
	panel.visible = show

func _slide_menu(menu: Control, show: bool) -> void:
	if menu.visible == show:
		return
	var base_y : float = panel.global_position.y
	var hidden_y : float = base_y + menu.size.y
	var show_y   : float = base_y

	var from_y : float = hidden_y if show else show_y
	var to_y   : float = show_y  if show else hidden_y

	if show:
		menu.global_position.y = from_y
		menu.visible = true

	if tween_ui and tween_ui.is_running():
		tween_ui.kill()

	tween_ui = create_tween()
	tween_ui.tween_property(menu, "global_position:y", to_y, 0.25) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT) \
			.finished.connect(Callable(self, "_on_menu_tween_finished").bind(menu, show))

func _on_menu_tween_finished(menu: Control, show: bool) -> void:
	if not show:
		menu.visible = false

# ─── 11. 텍스트 타이핑 출력 ─────────────────────────────────
func _show_current_message():
	txt.text = ""
	btn.disabled = true
	_type_text(messages[msg_index])

func _type_text(line:String) -> void:
	for ch in line:
		txt.text += ch
		beep.play()
		await get_tree().create_timer(typing_speed).timeout
	btn.disabled = false

# ─── 12. “다음/확인” 버튼 클릭 ───────────────────────────────
func _on_next() -> void:
	# ① 같은 세트의 다음 줄이 남아 있으면 계속 타이핑
	if msg_index + 1 < messages.size():
		msg_index += 1
		_show_current_message()
		return
	# ② 문구 세트가 끝났으면 _next_after_text 단계로 이동
	match _next_after_text:
		Phase.MOBILE_HINT:  _enter_mobile_hint()
		Phase.MOBILE_PLAY:  _enter_mobile_play()
		Phase.MILK_PRAISE:  _enter_milk_praise()
		Phase.MILK_HINT:
			baby.texture = baby_almost_cry_tex          # ★ 울기 직전 표정
			_enter_milk_hint()                          #   안내 단계로
		Phase.MILK_PLAY:    _enter_milk_play()
		Phase.END:          _enter_end()
		-1: get_tree().change_scene_to_file("res://Scenes/StageSelect.tscn")

# ─── 13. 드래그 완료(버튼 스크립트 emit) 처리 ─────────────────
func _on_drag_completed(data:Dictionary) -> void:
	var tex   : Texture2D = data.texture
	var scale : float     = data.scale
	var meta  : Dictionary = data.get("meta", {})

	# ── 13-A. 모빌 단계 성공
	if phase == Phase.MOBILE_PLAY:
		attach.texture = tex
		attach.scale   = Vector2.ONE * scale
		attach.visible = true
		mobile_attached = true
		baby.texture   = baby_reach_tex        # 손 뻗는 표정
		sfx_drop.play(); fx_particle.restart()
		_enter_milk_praise()                   # 칭찬 단계로 진입
		return

	# ── 13-B. 분유 단계
	if phase == Phase.MILK_PLAY:
		# (i) 온도가 적당
		if meta.get("type") == CORRECT_MILK_TYPE:
			milk_attach.texture = tex
			milk_attach.scale   = Vector2.ONE * milk_attach_scale
			milk_attach.visible = true
			baby.texture        = baby_default_tex
			sfx_drop.play(); fx_particle.restart()
			_enter_end()
		# (ii) 찬/뜨거운 분유 → 재시도
		else:
			baby.texture = baby_cry_tex
			sfx_wrong.play()
			_enter_text_phase(
				["앗! 온도가 맞지 않아요.\n적당한 분유를 다시 시도해 보세요."],
				Phase.MILK_HINT, Phase.MILK_PLAY
			)
