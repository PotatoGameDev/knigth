extends Node2D

@onready var millipedes_path_follows: Array[PathFollow2D] = []
@onready var millipedes_head: Node2D = $Millipedes/Head
@onready var camera: Camera2D = $Ritter/Camera2D
@export var millipedes_speed := 100.0

var millipedes_path_progress_goal := 1.0
var millipedes_direction := 1.0

func _ready() -> void:
	for child in $Path2D.get_children():
		if child is PathFollow2D:
			millipedes_path_follows.append(child)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()


	for millipedes_path_follow in millipedes_path_follows:
		if millipedes_path_follow.progress_ratio >= 1.0 and millipedes_direction == 1.0:
			millipedes_direction = -1.0
		elif millipedes_path_follow.progress_ratio <= 0.0 and millipedes_direction == -1.0:
			millipedes_direction = 1.0

		millipedes_head.direction = millipedes_direction
		millipedes_path_follow.progress += delta * millipedes_speed * millipedes_direction


	if Input.is_key_pressed(KEY_5):
		if camera.zoom < Vector2(0.5, 0.5):
			camera.zoom = Vector2.ONE
		else:
			camera.zoom = Vector2.ONE * 0.1
