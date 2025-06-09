extends Area2D

signal child_clicked

var dragging = false
var drag_offset = Vector2.ZERO

func _ready():
	monitoring = true
	monitorable = true  # 이거 꼭 있어야 함

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not _is_occluded():
			emit_signal("child_clicked")

func _is_occluded() -> bool:
	var areas = get_overlapping_areas()
	for area in areas:
		if area.name.begins_with("Crowd"):
			return true
	return false
