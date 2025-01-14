extends CharacterBody2D
class_name Knight

@export var jump_force := 1500.0
@export var speed := 200.0
@export var max_fall_speed := 2000.0
@export var jump_hold_time = 0.2
@export var max_coyote_time = 0.2
@export var max_queued_jump_time = 0.2
@export var jump_stamina_depletion_multiplier = 50.0
@export var step_speed := 150.0
@export var step_speed_min := 20.0
@export var smash_speed_damage_factor := 0.03

# Character stats
@export var strength := 10.0
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

var cling_blocker := false

@onready var animation: AnimatedSprite2D = $Animation

@onready var jump_ray_left_outer: RayCast2D = $JumpSlipRays/RayLeftOuter
@onready var jump_ray_left_inner: RayCast2D = $JumpSlipRays/RayLeftInner
@onready var jump_ray_right_outer: RayCast2D = $JumpSlipRays/RayRightOuter
@onready var jump_ray_right_inner: RayCast2D = $JumpSlipRays/RayRightInner

@onready var enemy_smash_sensor: ShapeCast2D = $Sensors/EnemySmashSensor

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

func is_left() -> bool:
	return direction == Global.LEFT

func is_right() -> bool:
	return direction == Global.RIGHT


@onready var running_state: RunningState =  $States/Running
@onready var idle_state: IdleState = $States/Idle
@onready var falling_state: FallingState = $States/Falling
@onready var jumping_state: JumpingState = $States/Jumping
@onready var smashing_state: SmashingState = $States/Smashing
@onready var bouncing_state: BouncingState = $States/Bouncing
@onready var stomping_state: StompingState = $States/Stomping
@onready var clinging_state: ClingingState = $States/Clinging
@onready var pushback_state: PushBackState = $States/PushBack

@onready var stamina_bar: ProgressBar = $HUD/StaminaBar
@onready var life_bar: ProgressBar = $HUD/LifeBar

func _ready() -> void:
	change_state(idle_state)
	jump_stamina_left = max_stamina
	health = max_health
	update_life_bar()
	current_state_entered_time = Time.get_ticks_msec()

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
	current_state.physics_update(self, delta)


func take_damage(damage: int, dir: Vector2) -> void:
	current_state.take_damage(self, damage, dir)
	update_life_bar()

func update_life_bar() -> void:
	life_bar.value = health / max_health
	if health <= 0:
		life_bar.visible = false

func is_alive() -> bool:
	return health > 0.0

func jump_slip():
	if jump_ray_left_outer.is_colliding() and not jump_ray_left_inner.is_colliding():
		velocity.x += speed
	elif jump_ray_right_outer.is_colliding() and not jump_ray_right_inner.is_colliding():
		velocity.x -= speed
