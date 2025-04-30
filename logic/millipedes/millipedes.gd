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

@onready var wheel: RigidBody2D = $MilipedesWheel
@onready var wheelCollisionShape: CollisionShape2D = $MilipedesWheel/CollisionShape2D
@onready var wheelRemoteTransform: RemoteTransform2D = $MilipedesWheel/RemoteTransform2D

@export var ritter: Knight = null

var health := 0.0
var state := State.FOLLOW_PATH

var transition := false

@export var roll_speed := 1000
var roll_direction := 1

enum State {
	FOLLOW_PATH,
	ATTACK,
	CURL,
}

func _on_antenna_ritter_detected(detected_ritter: Knight):
	if transition:
		return

	if state == State.FOLLOW_PATH:
		reset_to_curl()
		return

	if state == State.CURL:
		reset_to_ground_fight()
		return

func _on_antenna_ritter_lost():
	pass

var direction := Global.RIGHT
var head_index := 0

func _ready() -> void:
	follow_mode()
	health = max_health

	ritter = Global.ritter

func reset(fabrik: bool):
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

func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(
		wheelCollisionShape.global_position, 
		wheelCollisionShape.global_position + Vector2.RIGHT * 100,
		1 << 7,
		[self]
		)
	var result = space_state.intersect_ray(query)
	if result:
		roll_direction = -1

	query = PhysicsRayQueryParameters2D.create(
		wheelCollisionShape.global_position, 
		wheelCollisionShape.global_position + Vector2.LEFT * 100,
		1 << 7,
		[self]
		)
	result = space_state.intersect_ray(query)
	if result:
		roll_direction = 1


func _process(delta):
	if transition:
		return

	if health > 0.0 and Input.is_key_pressed(KEY_Y):
		health = 0.0	 
		death(10)
		return

	if health <= 0:
		return

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

		if segments[-1].rotation != 0:
			segments[-1].rotation = lerp_angle(segments[-1].rotation, 0, 0.1)

		attack_target.global_position = ritter.global_position

		# TODO: actual gravity here
		segments[-1].move_and_collide(Vector2.DOWN * Global.gravity * delta)

		# This probably doesn't work
		if ritter.global_position.x > segments[0].global_position.x:
			direction = Global.RIGHT
			scale.x = 1
		else:
			direction = Global.LEFT
			scale.x = 1 # TODO: flip (first figure out how to do this)
	
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

	if state == State.CURL:
		wheel.apply_central_impulse(roll_direction * Vector2.RIGHT * roll_speed)
		return


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
	transition = true

	state = State.ATTACK

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

	skeleton.get_modification_stack().enabled = false

	segments[head_index].collision_mask |= 1 << 7
	segments[head_index].global_rotation = 0

	animation_player.play_with_capture("stand_up")


func reset_to_curl():
	transition = true

	state = State.CURL

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

	animation_player.play_with_capture("curl")

func set_wheel_enabled(enabled: bool):
	transition = false
	if enabled:
		wheel.global_position = segments[head_index].global_position
		wheel.rotation = segments[head_index].rotation
		wheelRemoteTransform.update_position = true
		wheelRemoteTransform.update_rotation = true
		wheelCollisionShape.disabled = false
		wheel.sleeping = false
		wheel.freeze = false
	else:
		wheelRemoteTransform.update_position = false
		wheelRemoteTransform.update_rotation = false
		wheelCollisionShape.disabled = true
		wheel.sleeping = true
		wheel.freeze = true
