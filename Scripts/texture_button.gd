extends TextureButton

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/tutorial_scene.tscn")
