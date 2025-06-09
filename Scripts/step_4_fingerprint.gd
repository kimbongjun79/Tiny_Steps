extends Node2D

@onready var nextbutton = $Button
@onready var childSound = $childSound


func _ready():
	nextbutton.pressed.connect(_on_next_button_pressed)
	childSound.play()
	nextbutton.visible = true

func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/clear_stage_3.tscn")
