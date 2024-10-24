extends CharacterBody2D
class_name Knight

@export var jump_force := 1500.0
@export var gravity := 1200.0
@export var speed := 200.0
@export var max_fall_speed := 900.0
@export var jump_hold_time = 0.2
@export var max_coyote_time = 0.2
@export var max_queued_jump_time = 0.2

# Character stats
@export var strength := 100.0

var jump_timer := 0.0
var coyote_timer := 0.0
var queued_jump_timer := 0.0

var states = {} 
var current_state = null

var direction = 1
var movement = 0.0

@onready var animation = $Animation

@onready var jumpRayLeftOuter: RayCast2D = $JumpSlipRays/RayLeftOuter
@onready var jumpRayLeftInner: RayCast2D = $JumpSlipRays/RayLeftInner
@onready var jumpRayRightOuter: RayCast2D = $JumpSlipRays/RayRightOuter
@onready var jumpRayRightInner: RayCast2D = $JumpSlipRays/RayRightInner

@onready var enemySmashSensor: ShapeCast2D = $Sensors/EnemySmashSensor

@onready var running_state: RunningState =  $States/Running
@onready var idle_state: IdleState = $States/Idle
@onready var falling_state: FallingState = $States/Falling
@onready var jumping_state: JumpingState = $States/Jumping
@onready var smashing_state: SmashingState = $States/Smashing
@onready var bouncing_state: BouncingState = $States/Bouncing

func _ready() -> void:
	change_state(idle_state)

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

func _physics_process(delta):
	current_state.update(self, delta)
	move_and_slide()
