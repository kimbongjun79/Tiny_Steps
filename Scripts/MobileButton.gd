# MobileButton.gd
extends TextureButton       # ← 여기를 TextureButton2D → TextureButton 로 변경

# 드래그 시작 시 호출되는 콜백 (메서드 이름에도 언더바!)
func _get_drag_data(position: Vector2) -> Variant:
	# 프리뷰로 사용할 Control 노드 생성
	var preview = TextureRect.new()
	preview.texture = texture_normal
	preview.rect_scale = Vector2(0.6, 0.6)
	set_drag_preview(preview)
	return texture_normal

# (드롭 타겟 쪽에서는 _can_drop_data/_drop_data를 사용합니다)
