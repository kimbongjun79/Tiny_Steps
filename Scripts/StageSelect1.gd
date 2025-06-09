extends Control

@export var total_stages: int = 5
@export var unlocked_stages: int = 3

func _ready():
	var grid = $StageGrid
	grid.columns = 3

	for i in range(total_stages):
		var btn = Button.new()
		btn.text = "Stage %d" % (i + 1)
		btn.name = "Stage%d" % (i + 1)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		if i >= unlocked_stages:
			btn.disabled = true
			btn.text += " 🔒"

		btn.pressed.connect(_on_stage_button_pressed.bind(i + 1))
		grid.add_child(btn)

	$BackButton.pressed.connect(_on_back_pressed)

func _on_stage_button_pressed(stage_number: int) -> void:
	print("Stage %d selected!" % stage_number)
	var scene_path = "res://Stages/Stage%d.tscn" % stage_number
	if ResourceLoader.exists(scene_path):
		var stage_scene = load(scene_path)
		get_tree().change_scene_to_packed(stage_scene)
	else:
		print("스테이지 파일이 존재하지 않아요: ", scene_path)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
