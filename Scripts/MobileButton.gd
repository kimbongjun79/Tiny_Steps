extends TextureButton
const SCALE := 0.2                       # 20 %

func _get_drag_data(_pos):
	hide()                               # ① 원본 숨김

	# 루트 컨테이너 (크기는 0,0 그대로)
	var holder := Control.new()

	# 실제 이미지가 들어갈 TextureRect -----------------
	var img := TextureRect.new()
	img.texture      = texture_normal
	img.expand       = true
	img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var sz := texture_normal.get_size() * SCALE
	img.custom_minimum_size = sz
	img.size = sz
	img.position = -sz * 0.5             # ② 커서 기준 -½ 위치 → 중앙 정렬

	holder.add_child(img)                # 루트에 삽입
	set_drag_preview(holder)             # ③ 프리뷰 등록
	return texture_normal

# 드래그 종료(성공‧실패) → 버튼 복원 --------------------
func _notification(what):                # Godot 4
	if what == Control.NOTIFICATION_DRAG_END:
		show()
