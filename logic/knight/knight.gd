extends CharacterBody2D
class_name Knight

@export var jump_force := 1500.0
@export var acceleration := 2000
@export var max_speed := 500
@export var jump_hold_time = 0.2
@export var max_coyote_time = 0.2
@export var max_queued_jump_time = 0.2
@export var jump_stamina_depletion_multiplier = 50.0
@export var step_speed := 150.0
@export var step_speed_min := 20.0
@export var smash_speed_damage_factor := 0.03
@export var max_potential_energy := 8000.0 

# Character stats
@export var strength := 10.0
@export var weight := 10.0
@export var max_stamina := 1000.0
@export var max_health := 1000.0
@export var max_jumps := 2

var jump_stamina_left := 0.0
var jump_timer := 0.0
var coyote_timer := 0.0
var queued_jump_timer := 0.0
var current_jump := 0

var states = {} 
var current_state: KnightState = null
var current_state_entered_time: int = 0

var direction = Global.RIGHT
# TODO: Change to vector?
var movement = 0.0
var movement_vertical = 0.0

var bounce_power := 1.0

# Current stats
var health := 0.0
var air_drag := 0.1
var min_damage := 0.0

# current state 
var cling_blocker := false
var potential_energy := 0.0

@onready var camera: Camera2D = $Camera2D
var min_camera_zoom := Vector2.ONE * 0.5
var max_camera_zoom := Vector2.ONE * 1.0

@onready var animation: AnimatedSprite2D = $Animation

@onready var jump_ray_left_outer: RayCast2D = $JumpSlipRays/RayLeftOuter
@onready var jump_ray_left_inner: RayCast2D = $JumpSlipRays/RayLeftInner
@onready var jump_ray_right_outer: RayCast2D = $JumpSlipRays/RayRightOuter
@onready var jump_ray_right_inner: RayCast2D = $JumpSlipRays/RayRightInner

@onready var enemy_smashing_sensor: ShapeCast2D = $Sensors/EnemySmashSensor
@onready var floor_sensor_right: RayCast2D = $Sensors/FloorSensorRight
@onready var floor_sensor_left: RayCast2D = $Sensors/FloorSensorLeft

# The logic is: If the UP sensor is not colliding and the DOWN sensor is colliding, then the player should auto-jump the step up.
# If both are colliding, then the player can cling.
@onready var cling_blocker_sensor_left_up: RayCast2D = $Sensors/ClingBlockerSensors/LeftUp
@onready var cling_blocker_sensor_left_down: RayCast2D = $Sensors/ClingBlockerSensors/LeftDown
@onready var cling_blocker_sensor_right_up: RayCast2D = $Sensors/ClingBlockerSensors/RightUp
@onready var cling_blocker_sensor_right_down: RayCast2D = $Sensors/ClingBlockerSensors/RightDown

func can_cling_left() -> bool:
	return cling_blocker_sensor_left_up.is_colliding() and cling_blocker_sensor_left_down.is_colliding()

func can_cling_right() -> bool:
	return cling_blocker_sensor_right_up.is_colliding() and cling_blocker_sensor_right_down.is_colliding()

func can_step_left() -> bool:
	return not cling_blocker_sensor_left_up.is_colliding() and cling_blocker_sensor_left_down.is_colliding()

func can_step_right() -> bool:
	return not cling_blocker_sensor_right_up.is_colliding() and cling_blocker_sensor_right_down.is_colliding()

func can_smash() -> bool:
	return potential_energy >= max_potential_energy

func is_left() -> bool:
	return direction == Global.LEFT

func is_right() -> bool:
	return direction == Global.RIGHT

func get_floor_friction() -> float:
	if floor_sensor_left.is_colliding():
		var fl = floor_sensor_left.get_collider()
		if fl is TileMapLayer:
			return fl.tile_set.get_physics_layer_physics_material(0).friction
		if fl is StaticBody2D: 
			return fl.get_friction()
	if floor_sensor_right.is_colliding():
		var fl = floor_sensor_right.get_collider()
		if fl is TileMapLayer:
			return fl.tile_set.get_physics_layer_physics_material(0).friction
		if fl is StaticBody2D: 
			return fl.get_friction()
	return 0.9

func is_touching_floor() -> bool:
	return floor_sensor_left.is_colliding() or floor_sensor_right.is_colliding()

@onready var running_state: RunningState =  $States/Running
@onready var idle_state: IdleState = $States/Idle
@onready var falling_state: FallingState = $States/Falling
@onready var jumping_state: JumpingState = $States/Jumping
@onready var smashing_state: SmashingState = $States/Smashing
@onready var stomping_state: StompingState = $States/Stomping
@onready var clinging_state: ClingingState = $States/Clinging
@onready var pushback_state: PushBackState = $States/PushBack

@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var life_bar: ProgressBar = $HUD/LifeBar
@onready var potential_energy_bar: ProgressBar = $HUD/PotentialEnergyBar

func _ready() -> void:
	change_state(idle_state)
	jump_stamina_left = max_stamina
	health = max_health
	update_life_bar()
	current_state_entered_time = Time.get_ticks_msec()
	min_damage = weight

func change_state(to_state, params: Dictionary = {}) -> void:
	var elapsed_time = Time.get_ticks_msec() - current_state_entered_time
	if elapsed_time > 1000:
		print("[", elapsed_time / 1000.0, "s] Changing state to ", to_state.name)
	else:
		print("[", elapsed_time, "ms] Changing state to ", to_state.name)

	if current_state:
		current_state.exit(self)
	current_state = to_state
	current_state.enter(self, params)


	current_state_entered_time = Time.get_ticks_msec()

func _unhandled_input(event):
	# DO NOT use precalculated movement here
	if current_state:
		current_state.handle_input(self, event)

func _process(delta):
	print("Current jump: ", current_jump)
	if not current_state:
		return

	if Input.is_key_pressed(KEY_T):
		print("=================== DEBUd ======================")


	if current_state.options.calculate_movement:
		movement = Input.get_axis("left", "right")
		if current_state.options.calculate_direction:
			if movement != 0.0:
				direction = sign(movement)

	animation.flip_h = direction == Global.LEFT

	movement_vertical = Input.get_axis("down", "up")

	# Handle queued jumps
	if current_state.options.calculate_queued_jump_timer:
		queued_jump_timer -= delta
		if Input.is_action_just_pressed("jump"):
			queued_jump_timer = max_queued_jump_time

	stamina_bar.value = jump_stamina_left / max_stamina

	current_state.update(self, delta)


func _physics_process(delta):
	if not current_state:
		return

	if current_state.options.add_gravity:
		velocity.y += Global.gravity * delta



	current_state.physics_update(self, delta)


	# RULE: Potential energy is a non-negative number that represents the amount of energy that can be used to smash enemies.
	if velocity.y < 0.0:
		potential_energy += -velocity.y
	

		
	# RULE: Potential energy does not decrease, it's consumable only.
	#else:
	#	potential_energy -= velocity.y
	
	potential_energy = clamp(potential_energy, 0.0, max_potential_energy)
	update_potential_energy_bar()
	
	if velocity.length() > 100.0:
		camera.zoom = lerp(camera.zoom, min_camera_zoom, clampf(velocity.length()/10000.0, 0.0, 1.0))
	else:
		camera.zoom = lerp(camera.zoom, max_camera_zoom, 0.01)

	#if is_touching_floor():
	#	velocity.y = 0.0



func take_damage(damage: int, dir: Vector2) -> void:
	current_state.take_damage(self, damage, dir)
	update_life_bar()

func update_life_bar() -> void:
	life_bar.value = health / max_health
	if health <= 0:
		life_bar.visible = false

func update_potential_energy_bar() -> void:
	potential_energy_bar.value = potential_energy / max_potential_energy
	potential_energy_bar.visible = potential_energy > 0.0

func is_alive() -> bool:
	return health > 0.0

func jump_slip(delta: float) -> void:
	if jump_ray_left_outer.is_colliding() and not jump_ray_left_inner.is_colliding():
		velocity.x += acceleration * delta
	elif jump_ray_right_outer.is_colliding() and not jump_ray_right_inner.is_colliding():
		velocity.x -= acceleration * delta

func add_force(force: Vector2) -> void:
	print("Adding force: ", force)
	current_state.add_force(self, force)

