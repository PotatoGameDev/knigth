extends Area2D

var level_placeholder: InstancePlaceholder
var level_path: String

var level_instance: Node

func _ready():
	set_process(false)
	level_placeholder = get_parent()
	level_path = level_placeholder.get_instance_path()

	connect("body_entered", _on_body_entered)


func _process(_delta):
	var status = ResourceLoader.load_threaded_get_status(level_path)
	if status != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		return
	set_process(false)
	level_instance = level_placeholder.create_instance()

func _on_body_entered(body):
	if level_instance:
		return

	if body is Knight:
		ResourceLoader.load_threaded_request(level_path)
		set_process(true)
