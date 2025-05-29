extends Control
@onready var tutorial = get_parent()

func _can_drop_data(_pos, data) -> bool:
	# texture+scale 딕셔너리인지 확인
	return typeof(data) == TYPE_DICTIONARY and data.has("texture")

func _drop_data(_pos, data) -> void:
	get_parent().emit_signal("drag_completed", data)   # 직접 컨트롤러로
