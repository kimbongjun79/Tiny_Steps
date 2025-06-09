extends Node2D

@onready var nextbutton = $UI/nextButton
@onready var photo_eatIce = $photo2
@onready var photo_inPark = $photo1
@onready var photo_inHome = $photo3
@onready var nextbutton_sound = $Sound/nextSound


func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/step_3.tscn")

	
