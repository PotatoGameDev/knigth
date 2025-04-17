extends Node2D
class_name Millipedes

@export var segments : Array[Node2D] = []
@export var distance_to_follower : float = 8.0
@export var speed := 100.0
@export var max_health := 10000.0

@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var attack_target: Node2D = $AttackTarget
@onready var life_bar: ProgressBar = $HUD/LifeBar

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var ritter: Knight = null

var health := 0.0
var state := State.FOLLOW_PATH
var action := Action.DEFAULT

enum State {
	FOLLOW_PATH,
	ATTACK,
	CURL,
}

enum Action {
	DEFAULT,
	SPRING,
	FOLLOW_RITTER,
	COOLDOWN,
	CHARGE,
}

func _on_antenna_ritter_detected(detected_ritter: Knight):
	if state == State.FOLLOW_PATH:
		head_index = segments.size() - 1

		for i in range(segments.size()):
			var segment = segments[i]
			segment.remote_transform_for_controlling_bone.update_position = true
			segment.remote_transform_for_controlling_bone.update_rotation = true

			# for everything that's before the head, we enable bone controls
			for c in segment.controlling_bone.get_children():
				if c is RemoteTransform2D:
					c.update_position = i < head_index
					c.update_rotation = i < head_index
					break

			# disable path follow
			if segment.path_follow:
				segment.path_follow.get_children()[0].update_position = false
				segment.path_follow.get_children()[0].update_rotation = false

			segment.sync_to_physics = false

		skeleton.get_modification_stack().enabled = false

		# TODO: Change to dedicated character controllers.
		segments[head_index].collision_mask |= 1 << 7

		# Do not rotate instantly if you don't want it to be rotated instantly
		#segments[head_index].rotation = -90

		animation_player.play_with_capture("curl")
		
		state = State.CURL

	else:
		pass
	
	#reset_to_ground_fight()

func _on_antenna_ritter_lost():
	pass

var direction := Global.RIGHT
var head_index := 0

func _ready() -> void:
	follow_mode()
	health = max_health

	ritter = Global.ritter

func reset(fabrik: bool):
	print("Resetting ", head_index)
	for i in range(segments.size()):
		var segment = segments[i]
		# segment.remote_transform_for_controlling_bone.update_position = head_index == i
		# segment.remote_transform_for_controlling_bone.update_rotation = head_index == i
		segment.remote_transform_for_controlling_bone.update_position = true
		segment.remote_transform_for_controlling_bone.update_rotation = true

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
			pass

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

	if state == State.ATTACK:
		attack_target.global_position = ritter.global_position

	if state == State.FOLLOW_PATH:
		var current_progress = 0.0

		for i in range(segments.size()):
			var segment = segments[i]
			if i == 0:
				if segment.path_follow:
					segment.path_follow.progress += delta * speed * direction
					current_progress = segment.path_follow.progress
			else:
				current_progress -= distance_to_follower * direction
				segment.path_follow.progress = current_progress
	
		return
	if state == State.ATTACK:
		# TODO: actual gravity here
		segments[-1].move_and_collide(Vector2.DOWN * Global.gravity * delta)

		if ritter.global_position.x > segments[0].global_position.x:
			direction = Global.RIGHT
			scale.x = 1
		else:
			direction = Global.LEFT
			scale.x = 1 # TODO: flip
	
		if ritter.global_position.distance_to(segments[0].global_position) < 200:
			skeleton.get_modification_stack().enabled = true
			skeleton.get_modification_stack().strength = lerp(
				skeleton.get_modification_stack().strength, 1.0, 0.1
			)
		else:
			if skeleton.get_modification_stack().enabled:
				skeleton.get_modification_stack().strength = lerp(
					skeleton.get_modification_stack().strength, 0.0, 0.1
				)
				if skeleton.get_modification_stack().strength <= 0.0:
					skeleton.get_modification_stack().enabled = false

		return
	#if state == State.CURL:
		# TODO: actual gravity here
		#segments[-1].move_and_collide(Vector2.DOWN * Global.gravity * delta)


# TODO: REMOVE
func attack_mode() -> void:
	head_index = 15
	reset(true)

# TODO: REMOVE
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
		return
	
	if state == State.FOLLOW_PATH:
		state = State.ATTACK
		reset_to_ground_fight()
		return

func death(final_damage: int) -> void: # fun
	var center : int = segments.size() / 2.0 as int
	var center_segment = segments[center]

	for i in range(segments.size()):
		var old_node = segments[i]
		var new_node = RigidBody2D.new()
		new_node.name = old_node.name
		new_node.position = old_node.position
		new_node.rotation = old_node.rotation
		new_node.collision_layer = old_node.collision_layer
		new_node.collision_mask = 1 << 7
		print("Setting collision mask to: ", i)

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

func reset_to_ground_fight():
	head_index = segments.size() - 1

	for i in range(segments.size()):
		var segment = segments[i]
		segment.remote_transform_for_controlling_bone.update_position = head_index == i
		segment.remote_transform_for_controlling_bone.update_rotation = head_index == i

		# for everything that's before the head, we enable bone controls
		for c in segment.controlling_bone.get_children():
			if c is RemoteTransform2D:
				c.update_position = i < head_index
				c.update_rotation = i < head_index
				break

		if segment.path_follow:
			segment.path_follow.get_children()[0].update_position = false
			segment.path_follow.get_children()[0].update_rotation = false

		segment.sync_to_physics = false

	# iterate over bones in skeleton and apply rest
	for i in range(head_index, skeleton.get_bone_count()):
		var bone = skeleton.get_bone(i)
		bone.apply_rest()

	skeleton.get_modification_stack().enabled = false

	segments[head_index].collision_mask |= 1 << 7
	segments[head_index].rotation = 0

	state = State.ATTACK

func reset_to_curl():
	head_index = segments.size() - 1

	for i in range(segments.size()):
		var segment = segments[i]
		segment.remote_transform_for_controlling_bone.update_position = true
		segment.remote_transform_for_controlling_bone.update_rotation = true

		# for everything that's before the head, we enable bone controls
		for c in segment.controlling_bone.get_children():
			if c is RemoteTransform2D:
				# Commenting those out makes the animations work, go figure:
				#c.update_position = i < head_index
				#c.update_rotation = i < head_index
				break

		if segment.path_follow:
			segment.path_follow.get_children()[0].update_position = false
			segment.path_follow.get_children()[0].update_rotation = false


		segment.sync_to_physics = false

	skeleton.get_modification_stack().enabled = false

	# TODO: Change to dedicated character controllers.
	segments[head_index].collision_mask |= 1 << 7
	segments[head_index].rotation = -90

	state = State.CURL

