extends Node2D

@onready var baby = $BabyImg
@onready var phone = $hand
@onready var label = $Label

var speed = 150  # 아이 이동 속도 (픽셀/초)

func _ready():
	print(label)
	#label.text = "아이를 핸드폰 안에 들어왔을 때 찍어주세요!"

func _process(delta):
	baby.position.x += speed * delta

	# 화면 오른쪽 벗어나면 다시 왼쪽으로
	if baby.position.x > get_viewport_rect().size.x + 100:
		baby.position.x = -100
