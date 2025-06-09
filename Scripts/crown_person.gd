extends Area2D

var dragging = false
var drag_offset = Vector2.ZERO

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - event.position
		else:
			dragging = false

func _process(delta):
	if dragging:
		global_position = get_viewport().get_mouse_position() + drag_offset
		
		# 상위 씬에게 내가 움직였다고 알림
		var parent = get_tree().current_scene
		if parent.has_method("_update_child_visibility"):
			parent._update_child_visibility()
