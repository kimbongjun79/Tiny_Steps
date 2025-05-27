extends Control


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn") #임의로 지정한 씬 경로. 추후 수정 필요

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial_scene.tscn") #임의로 지정한 씬 경로. 추후 수정 필요


func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Stage_2.tscn") #임의로 지정한 씬 이름과 경로. 추후 수정 필요


func _on_texture_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Stage_3.tscn") #임의로 지정한 씬 이름과 경로. 추후 수정 필요


func _on_texture_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Stage_4.tscn") #임의로 지정한 씬 이름과 경로. 추후 수정 필요


func _on_texture_button_5_pressed() -> void:
	get_tree().change_scene_to_file("res://Stage_5.tscn") #임의로 지정한 씬 이름과 경로. 추후 수정 필요
