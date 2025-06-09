extends Area2D

@onready var icecream_sound = $icecreamShop

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		icecream_sound.play()
