extends Sprite2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	set_process_input(true)

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.position
		else:
			dragging = false

func _unhandled_input(event: InputEvent) -> void:
	if dragging and event is InputEventMouseMotion:
		global_position = get_viewport().get_mouse_position() + drag_offset
