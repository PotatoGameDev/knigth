extends Node2D

@onready var camera: Camera2D = $Ritter/Camera2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R):
		get_tree().reload_current_scene()


	if Input.is_key_pressed(KEY_5):
		if camera.zoom < Vector2(0.5, 0.5):
			camera.zoom = Vector2.ONE
		else:
			camera.zoom = Vector2.ONE * 0.1
