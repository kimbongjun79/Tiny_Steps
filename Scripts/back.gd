extends TextureButton

func _on_back_pressed() -> void:
	pass # Replace with function body.

func _on_texture_back_pressed():
	get_tree().change_scene_to_file("res://Title.tscn")
