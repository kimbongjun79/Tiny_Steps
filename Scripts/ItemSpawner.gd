extends Node2D

@export var item_scenes : Array[PackedScene]
@export var spawn_interval = 3.0
@export var baby : NodePath

var baby_ref : Node2D

func _ready():
	baby_ref = get_node(baby)
	spawn_items()

func spawn_items():
	var scene = item_scenes[randi() % item_scenes.size()]
	var instance = scene.instantiate()
	var offset = Vector2(randf_range(-200, 200), randf_range(-200, 200))
	instance.global_position = baby_ref.global_position + offset
	add_child(instance)
	await get_tree().create_timer(spawn_interval).timeout
	spawn_items()
