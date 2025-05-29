# MobileButton.gd   — Godot 4.x
#   • 드래그 시작 때 버튼을 숨기고
#   • 커서 중앙에 preview_scale 배율의 미리보기를 보여 준 뒤
#   • 드롭 시 {texture, scale, meta} 딕셔너리를 반환
extends TextureButton

@export var drop_scale    : float  = 0.70      # 천장/입에 붙일 최종 배율
@export var preview_scale : float  = 0.45      # 커서 미리보기 배율
@export var milk_type     : String = ""        # "cold" / "warm" / "hot" (모빌이면 빈 문자열)

# ───────────────────────────── 드래그 시작
func _get_drag_data(_pos):
	hide()                                      # 1) 원본 버튼 숨김

	# 2) 프리뷰 이미지 노드
	var tex_size : Vector2 = texture_normal.get_size()

	var pv := TextureRect.new()
	pv.texture = texture_normal
	pv.expand  = true
	pv.size    = tex_size                       # 원본 사이즈
	pv.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# —— (핵심) 피벗을 정중앙으로 이동
	pv.pivot_offset = tex_size * preview_scale * -0.5            # ► 중앙 pivot
	pv.scale        = Vector2.ONE * preview_scale
	pv.position     = Vector2.ZERO              # (0,0)=커서 ▶ pivot 에 일치

	set_drag_preview(pv)                        # 3) 커서에 부착

	# 4) 드롭 데이터
	var meta : Dictionary = {} if milk_type == "" else {"type": milk_type}
	return {
		"texture": texture_normal,
		"scale":   drop_scale,
		"meta":    meta
	}

# ───────────────────────────── 드래그 종료(취소 포함)
func _notification(what):
	if what == Control.NOTIFICATION_DRAG_END:
		show()                                  # 버튼 복구
