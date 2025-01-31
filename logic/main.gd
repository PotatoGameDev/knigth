extends Node2D

@onready var millipedes_path: PathFollow2D = $Path2D/PathFollow2D
@onready var camera: Camera2D = $Ritter/Camera2D
@export var millipedes_speed := 100.0

var millipedes_path_progress_goal := 1.0
var millipedes_direction := 1.0

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()


	if millipedes_path.progress_ratio >= 1.0 and millipedes_direction == 1.0:
		millipedes_direction = -1.0
	elif millipedes_path.progress_ratio <= 0.0 and millipedes_direction == -1.0:
		millipedes_direction = 1.0

	millipedes_path.progress += delta * millipedes_speed * millipedes_direction

	if Input.is_key_pressed(KEY_5):
		if camera.zoom < Vector2(0.5, 0.5):
			camera.zoom = Vector2.ONE
		else:
			camera.zoom = Vector2.ONE * 0.1
