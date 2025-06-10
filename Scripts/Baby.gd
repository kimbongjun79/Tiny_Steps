extends CharacterBody2D

@export var speed = 100
var direction = Vector2.ZERO

func _ready():
	randomize()
	set_random_direction()

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()

func set_random_direction():
	direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	await get_tree().create_timer(2.0).timeout
	set_random_direction()
