extends Node2D

@onready var label = $Label
@onready var particles = $CPUParticles2D
@onready var nextbutton = $Button
@onready var particleSound = $particle

var move_speed = 150
var reset_timer = null

func _ready():
	nextbutton.pressed.connect(_on_next_button_pressed)
	nextbutton.visible = true

func _process(delta):
	if label.position.x > get_viewport_rect().size.x:
		if reset_timer == null:
			reset_timer = get_tree().create_timer(1.5)
			await reset_timer.timeout
			label.position.x = -label.size.x
			reset_timer = null
	else:
		label.position.x += move_speed * delta


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		particles.global_position = event.position
		particles.emitting = true
		particleSound.play()
		
func _on_next_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/StageSelect.tscn")
	
