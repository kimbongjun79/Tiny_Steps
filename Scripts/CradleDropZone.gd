extends Control

@onready var tutorial = get_parent()

# Texture2D 데이터만 허용
func can_drop_data(position: Vector2, data: Variant) -> bool:
	return data is Texture2D

# 드랍되면 TutorialController 로 시그널 전송
func drop_data(position: Vector2, data: Variant) -> void:
	tutorial.emit_signal("step1_dropped", data)
