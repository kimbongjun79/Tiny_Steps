extends Sprite2D


var is_dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			is_dragging = true
		elif !event.pressed:
			is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		global_position += event.relative
