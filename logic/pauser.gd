
extends Node

@export var enabled := true
var next_frame: bool = false
var process_slowmo: bool = false

func _process(delta: float) -> void:

	if not enabled:
		return

	# If not paused and a next frame step is queued
	if not get_tree().paused and next_frame:
		get_tree().paused = true

	# Handle slow-motion processing
	if not get_tree().paused and process_slowmo:
		get_tree().paused = true
		await get_tree().create_timer(1.0).timeout  # Await the timeout signal
		get_tree().paused = false

	# Handle input for next frame step
	if get_tree().paused and Input.is_action_just_pressed("LMB"):
		next_frame = true
		process_slowmo = false
		get_tree().paused = false
		print("next frame")

	# Handle input for slow-motion processing
	if get_tree().paused and Input.is_action_just_pressed("RMB"):
		process_slowmo = true
		next_frame = false
		get_tree().paused = false
		print("process_slowmo")
		
	if (Input.is_key_pressed(KEY_0)):
		get_tree().paused = false
		

	# Toggle pause with MMB
	if Input.is_action_just_pressed("MMB"):
		if not get_tree().paused:
			get_tree().paused = true
			print("process paused")
		else:
			process_slowmo = false
			next_frame = false
			get_tree().paused = false
			print("process unpaused")
