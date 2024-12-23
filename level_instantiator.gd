extends Area2D

@export var level_scene: String

var level_placeholder: InstancePlaceholder

func _ready():
	level_placeholder = get_parent().get_node(level_scene)

	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body is Knight:
		level_placeholder.create_instance()
