extends Node2D
class_name Millipedes

@export var segments : Array[Node2D] = []
@export var distance_to_follower : float = 8.0
@export var speed := 100.0
@export var max_health := 10000.0

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var attack_target: Node2D = $AttackTarget
@onready var life_bar: ProgressBar = $HUD/LifeBar

@export var ritter: Knight = null

var follow_ritter := false
var health := 0.0

func _on_antenna_ritter_detected(detected_ritter: Knight):
	ritter = detected_ritter
	attack_mode()
	pass

func _on_antenna_ritter_lost():
	ritter = null
	follow_mode()

var direction := Global.RIGHT
var head_index := 0

func _ready() -> void:
	follow_mode()
	health = max_health

func reset(fabrik: bool):
	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.remote_transform_for_controlling_bone.update_position = head_index == i
		segment.remote_transform_for_controlling_bone.update_rotation = head_index == i

		# for everything that's before the head, we enable bone controls
		for c in segment.controlling_bone.get_children():
			if c is RemoteTransform2D:
				c.update_position = i < head_index
				c.update_rotation = i < head_index
				break

	for i in range(segments.size()):
		var segment = segments[i]
		if segment.path_follow:
			segment.path_follow.get_children()[0].update_position = i >= head_index
			segment.path_follow.get_children()[0].update_rotation = i >= head_index

	# iterate over bones in skeleton and apply rest
	for i in range(head_index, skeleton.get_bone_count()):
		var bone = skeleton.get_bone(i)
		bone.apply_rest()

	skeleton.get_modification_stack().enabled = fabrik

func _process(delta):
	if health > 0.0 and Input.is_key_pressed(KEY_Y):
		health = 0.0	 
		death(10)
		return

	if health <= 0:
		return

	var current_progress = 0.0

	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.animation.flip_h = direction == Global.LEFT

		if i == 0:
			if segment.path_follow:
				segment.path_follow.progress += delta * speed * direction
				current_progress = segment.path_follow.progress
		else:
			current_progress -= distance_to_follower * direction
			segment.path_follow.progress = current_progress
	
	if Input.is_key_pressed(KEY_0):
		attack_mode()
	elif Input.is_key_pressed(KEY_6):
		follow_mode()

	if ritter:
		attack_target.global_position = ritter.global_position

func attack_mode() -> void:
	head_index = 15
	reset(true)

func follow_mode() -> void:
	head_index = 0
	reset(false)

func get_friction() -> float:
	return 1.0

func update_life_bar() -> void:
	life_bar.value = health / max_health
	if health <= 0:
		life_bar.visible = false

func take_damage(damage: int) -> void:
	var health_before = health
	health -= damage
	update_life_bar()

	if (health <= 0):
		death(health_before)

func death(final_damage: int) -> void: # fun
	var center : int = segments.size() / 2.0 as int
	var center_segment = segments[center]

	for i in range(0, segments.size()):
		var old_node = segments[i]
		var new_node = RigidBody2D.new()
		new_node.name = old_node.name
		new_node.position = old_node.position
		new_node.rotation = old_node.rotation
		new_node.collision_layer = old_node.collision_layer
		new_node.collision_mask = 1 << 7

		for child in old_node.get_children():
			old_node.remove_child(child)
			if child is AnimatedSprite2D or child is CollisionShape2D or child is Sprite2D:
				new_node.add_child(child)
			if child is CollisionShape2D:
				child.one_way_collision = false

		add_child(new_node)
		remove_child(old_node)
		
		$HUD.queue_free()

		# Explosion
		var explosion_pos = center_segment.position + Vector2.DOWN * 10
		var force_dir = old_node.position - explosion_pos
		var max_length = 100
		var force = (max_length - force_dir.length()) * final_damage
		var max_force = 1000
		var force_mag = clamp(force, 0, max_force)

		new_node.apply_central_impulse(force_dir.normalized() * force_mag)


		
