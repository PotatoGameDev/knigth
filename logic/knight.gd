extends CharacterBody2D
class_name Knight

@export var jump_force := 1500.0
@export var gravity := 1200.0
@export var speed := 200.0
@export var max_fall_speed := 900.0
@export var jump_hold_time = 0.2
@export var max_coyote_time = 0.2

var jump_timer := 0.0
var coyote_timer := 0.0

var states = {} 
var current_state = null

var direction = 1

@onready var animation = $Animation

@onready var running_state: RunningState =  $States/Running
@onready var idle_state: IdleState = $States/Idle
@onready var falling_state: FallingState = $States/Falling
@onready var jumping_state: JumpingState = $States/Jumping

func _ready() -> void:
	change_state(idle_state)

func change_state(new_state) -> void:
	if current_state:
		current_state.exit(self)
	
	print("entering " + new_state.name)
	current_state = new_state
	current_state.enter(self)

func _process(delta):
	if not current_state:
		return
	current_state.handle_input(self)

	if is_on_floor():
		coyote_timer = max_coyote_time
	else:
		coyote_timer -= delta

func _physics_process(delta):
	current_state.update(self, delta)
	move_and_slide()
