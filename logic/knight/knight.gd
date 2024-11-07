extends CharacterBody2D
class_name Knight

@export var jump_force := 1500.0
@export var pushoff_force := 1000.0
@export var gravity := 1200.0
@export var speed := 200.0
@export var max_fall_speed := 900.0
@export var jump_hold_time = 0.2
@export var max_coyote_time = 0.2
@export var max_queued_jump_time = 0.2
@export var jump_stamina_depletion_multiplier = 50.0

@export var jump_cling_debounce_time = 0.2

# Character stats
@export var strength := 100.0
@export var stamina := 1000.0

var jump_stamina_left := 0.0
var jump_timer := 0.0
var coyote_timer := 0.0
var queued_jump_timer := 0.0

var states = {} 
var current_state = null

var direction = 1
var movement = 0.0

var bounce_power := 1.0
var is_bouncing := false

# TODO Find a better name:
var cling_blocker := false

@export var cling_pushoff_time := 0.1
var cling_pushoff_timer := 0.0

var last_on_floor_timer := 0.0


@onready var animation = $Animation

@onready var jumpRayLeftOuter: RayCast2D = $JumpSlipRays/RayLeftOuter
@onready var jumpRayLeftInner: RayCast2D = $JumpSlipRays/RayLeftInner
@onready var jumpRayRightOuter: RayCast2D = $JumpSlipRays/RayRightOuter
@onready var jumpRayRightInner: RayCast2D = $JumpSlipRays/RayRightInner

@onready var enemySmashSensor: ShapeCast2D = $Sensors/EnemySmashSensor
@onready var wallClingSensorRight: ShapeCast2D = $Sensors/WallClingSensorRight
@onready var wallClingSensorLeft: ShapeCast2D = $Sensors/WallClingSensorLeft

@onready var running_state: RunningState =  $States/Running
@onready var idle_state: IdleState = $States/Idle
@onready var falling_state: FallingState = $States/Falling
@onready var jumping_state: JumpingState = $States/Jumping
@onready var smashing_state: SmashingState = $States/Smashing
@onready var bouncing_state: BouncingState = $States/Bouncing
@onready var stomping_state: StompingState = $States/Stomping
@onready var clinging_state: ClingingState = $States/Clinging
@onready var pushoff_state: PushOffState = $States/PushOff

@onready var stamina_bar: ProgressBar = $HUD/StaminaBar

func _ready() -> void:
	change_state(idle_state)
	jump_stamina_left = stamina

func change_state(new_state) -> void:
	print("Changing state to ", new_state.name)
	if current_state:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)

func _process(delta):
	if not current_state:
		return

	current_state.handle_input(self)

	movement = Input.get_action_strength("right") - Input.get_action_strength("left")

	# Handle queued jumps
	queued_jump_timer -= delta
	if Input.is_action_just_pressed("jump"):
		queued_jump_timer = max_queued_jump_time

	stamina_bar.value = (jump_stamina_left / stamina) * 100.0

	if is_on_floor():
		last_on_floor_timer = 0.0
	else:
		last_on_floor_timer += delta

func _physics_process(delta):
	current_state.update(self, delta)
	move_and_slide()



