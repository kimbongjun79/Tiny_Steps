extends Control

# TutorialController 노드는 루트에 붙어 있으므로 get_parent() 로 바로 참조
@onready var tutorial = get_parent()

func _can_drop_data(position: Vector2, data: Variant) -> bool:
	return data is Texture2D

func _drop_data(position: Vector2, data: Variant) -> void:
	tutorial.emit_signal("step1_dropped", data)
