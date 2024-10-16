extends CharacterBody2D
class_name Knight

const GRAVITY = 9.8 * 60
const JUMP_VELOCITY = -400.0

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
	current_state.update(self, delta)


func _physics_process(_delta):
	move_and_slide()
