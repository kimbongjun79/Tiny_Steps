extends Node2D

@onready var timer = $Timer
@onready var item_container = $ItemContainer
@onready var result_label = $UILayer/ResultLabel
@onready var time_label = $UILayer/TimeLabel
@onready var baby = $Baby

var total_items = 7
var items_removed = 0
var time_left = 30
var hit_count := 0

var item_names = [
	"scissors",
	"hotpot",
	"detergent",
	"coffeepot",
	"glass",
	"blender",
	"trashbin"
]

func _ready():
	spawn_items()
	timer.timeout.connect(on_timeout)
	set_process(true)
	
	'''var baby_sprite = Sprite2D.new()
	baby_sprite.texture = load("res://assets/baby.png")
	baby.add_child(baby_sprite)
	'''
	# UI 위치 보정
	time_label.position = Vector2(1700, 30)
	result_label.position = Vector2(800, 500)

func _process(delta):
	time_left = max(0, time_left - delta)
	time_label.text = "남은 시간: %d" % int(time_left)
	if time_left <= 0:
		on_timeout()

	# 랜덤 이동 (간단한 예시)
	var target = get_closest_item()
	if target:
		var direction = (target.position - baby.position).normalized()
		
		# Sprite 노드 가져오기
		var baby_sprite = baby.get_node("Sprite")
		if baby_sprite:
			if direction.x > 0:
				baby_sprite.flip_h = true
			elif direction.x < 0:
				baby_sprite.flip_h = false
				
		
		# ✅ 충돌 체크 (여기서만 hit 처리)
		for item in item_container.get_children():
			if baby.position.distance_to(item.position) < 40:  # 거리 임계값은 적당히 조절 가능
				hit_count += 1  # 먼저 증가

				if hit_count >= 2:
					show_result("Game Over!")
					set_process(false)
				else:
					var item_hit_count = item.get_meta("hit_count")
					if item_hit_count == null:
						item_hit_count = 0
					item_hit_count += 1
					item.set_meta("hit_count", item_hit_count)

					if item_hit_count == 1:
						item.position = get_random_item_position()
		
			
			
		var speed = 150  # 원하는 속도 조절
		baby.position += direction * speed * delta
	baby.position = baby.position.clamp(Vector2(0, 0), Vector2(1920, 1080))

func spawn_items():
	for i in range(total_items):
		var item_name = item_names[i]
		var area = Area2D.new()
		var sprite = Sprite2D.new()
		sprite.texture = load("res://Assets/Images/stage2_img/%s.png" % item_name)
		area.position = Vector2(randf_range(100, 1820), randf_range(100, 980))
		area.add_child(sprite)

		var shape = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = Vector2(200, 200)
		shape.shape = rect_shape
		area.add_child(shape)

		area.name = item_name
		area.connect("input_event", on_item_clicked.bind(area))
		item_container.add_child(area)
		


func on_item_clicked(viewport, event, shape_idx, area):
	if event is InputEventMouseButton and event.pressed:
		item_container.remove_child(area)
		area.queue_free()
		items_removed += 1
		if items_removed >= total_items:
			show_result("성공!")

func get_closest_item():
	var closest = null
	var closest_dist = INF

	for item in item_container.get_children():
		var dist = baby.position.distance_to(item.position)
		if dist < closest_dist:
			closest = item
			closest_dist = dist

	return closest
	
func get_random_item_position():
	var margin = 100  # 화면 경계로부터 여백
	var screen_size = get_viewport().get_visible_rect().size

	var x = randf_range(margin, screen_size.x - margin)
	var y = randf_range(margin, screen_size.y - margin)

	return Vector2(x, y)
	
	
	
	
func _on_baby_area_entered(area):
	if area.is_in_group("item"):
		hit_count += 1

		if hit_count >= 2:
			show_result("Game Over!")
		else:
			# 아이템을 다른 위치로 옮기기
			area.position = get_random_item_position()	


func on_timeout():
	if items_removed < total_items:
		show_result("Game Over!")

func show_result(result_text):
	result_label.text = result_text  #  전달받은 메시지를 사용
	result_label.show()
	
	timer.stop()  #  타이머 멈춤 추가
	set_process(false)  # _process(delta) 중지도 확실하게
	
	if result_text == "성공!":
		$UILayer/next_button.show()
	elif result_text == "Game Over!":
		$UILayer/retry_button.show()
		$UILayer/main_button.show()
	
	
func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StageSelect.tscn")


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/BabyProtectionStage_livingroom.tscn")


func _on_main_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
