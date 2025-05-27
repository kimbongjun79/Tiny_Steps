extends Control


@onready var background_texture_rect = $TextureRect

@export var background_image_1: Texture2D
@export var background_image_2: Texture2D

func _ready():
	randomize()
	var images = [background_image_1, background_image_2]
	var random_index = randi() % images.size()
	background_texture_rect.texture = images[random_index]

	$"HBoxContainer/시작".pressed.connect(_on_start_button_pressed)
	$"HBoxContainer/안내문".pressed.connect(_on_notice_button_pressed)

func _on_start_button_pressed():
	print("시작 버튼 눌림")  # 디버깅용
	get_tree().change_scene_to_file("res://Scenes/StageSelect.tscn")
	
	
func _on_notice_button_pressed():
	print("안내문 버튼 눌림")
	get_tree().change_scene_to_file("res://Scenes/HowToPlay.tscn")
