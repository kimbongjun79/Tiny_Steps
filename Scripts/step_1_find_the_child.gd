extends Node2D

@onready var child = $Child
@onready var child_sprite = $Child/Sprite2D
@onready var next_button = $UI/HBoxContainer/Button
@onready var label = $UI/Label
@onready var shops = [$Shops/Shop1, $Shops/Shop2, $Shops/Shop3]
@onready var crown_node = $Crown

@onready var rightsound = $clickChild
@onready var backgroundsound = $backgroundSound




const CROWD_SCENE = preload("res://Scenes/CrownPerson.tscn")

var person_textures = [
	preload("res://Assets/Images/Crown/crowns_1.png"),
	preload("res://Assets/Images/Crown/crowns_2.png"),
	preload("res://Assets/Images/Crown/crowns_3.png")
]

func _ready():
	randomize()
	_randomize_child_position()
	_spawn_crowds()
	child.connect("child_clicked", Callable(self, "_on_child_child_clicked"))
	next_button.visible = false
	child.z_index = 0
	backgroundsound.play()
	label.text = "사람들 사이에서 아이를 찾아주세요! (사람들을 드래그해보세요)"

func _randomize_child_position():
	var rand_index = randi() % shops.size()
	var pos = shops[rand_index].global_position
	child.global_position = Vector2(pos.x, 800)

func _spawn_crowds():
	for i in range(17):
		var person = CROWD_SCENE.instantiate()
		person.name = "Crowd_%d" % i

		var texture_index = randi() % person_textures.size()
		var sprite_node = person.get_node("Sprite2D")
		sprite_node.texture = person_textures[texture_index]

		person.scale = Vector2(0.9 + randf() * 0.12, 0.9 + randf() * 0.12)

		var x = randi() % 3000 - 2500
		var y = randi() % 20 - 800
		person.position = Vector2(x, y)

		person.z_index = 1
		crown_node.add_child(person)

func _on_child_child_clicked():
	label.text = "아이를 찾았습니다!"
	rightsound.play()
	next_button.z_index = 1
	next_button.visible = true
	
#다음 step2로 가게 만들기
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/step_2_take_a_picture.tscn")
