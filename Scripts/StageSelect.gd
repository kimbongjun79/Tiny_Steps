extends Control


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn") 

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/tutorial_scene.tscn") 


func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/BabyProtectionStage_livingroom.tscn")


func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/step_1_find_the_child.tscn") 
