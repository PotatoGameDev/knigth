extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 20.0
const HEAD_SPEED := 400.0
const HISTORY_LENGTH := 10  # Number of steps to delay follow

var joints: Array[Vector2] = []
var history: Array[Array] = []

var target_position: Vector2

func _ready() -> void:
    var start = Vector2(100, 300)
    for i in range(SEGMENT_COUNT):
        joints.append(start - Vector2(i * BONE_LENGTH, 0))
        history.append([joints[i]])  # Init with starting pos

    target_position = joints[0]

func _process(delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        target_position = get_global_mouse_position()

    move_with_history(delta)
    queue_redraw()

func move_with_history(delta: float) -> void:
    # Move head toward target
    var head = joints[0]
    var to_target = target_position - head
    var move = to_target.normalized() * HEAD_SPEED * delta
    if move.length() > to_target.length():
        move = to_target
    joints[0] += move

    # Update history buffer for the head
    history[0].append(joints[0])
    if history[0].size() > HISTORY_LENGTH:
        history[0].pop_front()

    # For each other joint, follow the delayed position of the previous
    for i in range(1, SEGMENT_COUNT):
        # Ensure history exists
        if history[i - 1].size() >= HISTORY_LENGTH:
            var target_pos = history[i - 1][0]
            var dir = (joints[i] - target_pos).normalized()
            joints[i] = target_pos + dir * BONE_LENGTH

        # Save this joint's position to history
        history[i].append(joints[i])
        if history[i].size() > HISTORY_LENGTH:
            history[i].pop_front()

func _draw() -> void:
    for i in range(SEGMENT_COUNT - 1):
        draw_line(joints[i], joints[i + 1], Color.GREEN_YELLOW, 3.0)
