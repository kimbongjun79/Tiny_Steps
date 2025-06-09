extends Area2D

var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	set_process(true)
	z_index = randi() % 100  # 👈 각 군중마다 z_index 랜덤 설정

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _is_topmost_at(event.position):  # 👈 겹친 경우 top만 드래그 가능
				dragging = true
				drag_offset = global_position - event.position
		else:
			dragging = false

func _process(_delta):
	if dragging:
		global_position = get_viewport().get_mouse_position() + drag_offset

# 👇 현재 위치에 다른 군중이 위에 있는지 확인
func _is_topmost_at(pos: Vector2) -> bool:
	var parent = get_parent()
	if parent == null:
		return true
	for other in parent.get_children():
		if other == self:
			continue
		if not other.has_node("Sprite2D"):
			continue
		var sprite = other.get_node("Sprite2D")
		if sprite.texture == null:
			continue
		var size = sprite.texture.get_size() * sprite.scale
		var rect = Rect2(other.global_position - size / 2, size)
		if rect.has_point(pos) and other.z_index > z_index:
			return false
	return true
