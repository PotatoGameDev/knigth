extends CharacterBody2D
class_name Zombi 

@export var health := 100.0

@export var gravity := 1200.0
@export var speed := 200.0
@export var max_fall_speed := 900.0

var states = {} 
var current_state = null

var direction := 1
var movement := 0.0

@onready var animation = $Animation

@onready var running_state: ZombiRunningState =  $States/Running
@onready var idle_state: ZombiIdleState = $States/Idle
@onready var attacking_state: ZombiAttackingState = $States/Attacking
@onready var dead_state: ZombiDeadState = $States/Dead

@onready var attackRayRight: RayCast2D = $Sensors/AttackRayRight
@onready var attackRayLeft: RayCast2D = $Sensors/AttackRayLeft
@onready var detectorLeft: ShapeCast2D = $Sensors/DetectorLeft
@onready var detectorRight: ShapeCast2D = $Sensors/DetectorRight

@onready var stepTimer: Timer = $StepTimer

func _ready() -> void:
	change_state(idle_state)

func change_state(new_state) -> void:
	print("Z Changing state to ", new_state.name)
	if current_state == dead_state:
		return
	if current_state:
		current_state.exit(self)
	current_state = new_state
	current_state.enter(self)

func _process(_delta):
	if not current_state:
		return

func _physics_process(delta):
	if not current_state:
		return
	if current_state == dead_state:
		return
	current_state.update(self, delta)

	if health <= 0:
		change_state(dead_state)

	move_and_slide()

func take_damage(damage: int) -> void:
	health -= damage

func is_alive() -> bool:
	return health > 0.0

