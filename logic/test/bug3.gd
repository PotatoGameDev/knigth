extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 20.0
const SPEED := 200.0
const TURN_RATE := 8.0  # How quickly segments turn to follow the front one
const HEAD_SPEED := 300.0

var joints: Array[Vector2] = []
var velocities: Array[Vector2] = []

var target_position: Vector2

func _ready() -> void:
    var start = Vector2(100, 300)
    for i in range(SEGMENT_COUNT):
        joints.append(start - Vector2(i * BONE_LENGTH, 0))
        velocities.append(Vector2.RIGHT * SPEED)
    target_position = joints[0]

func _process(delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        target_position = get_global_mouse_position()

    move_snake_with_momentum(delta)
    queue_redraw()

func move_snake_with_momentum(delta: float) -> void:
    # Head: steer directly toward target
    var to_target = target_position - joints[0]
    if to_target.length() > 1.0:
        var desired_dir = to_target.normalized()
        velocities[0] = velocities[0].lerp(desired_dir * HEAD_SPEED, TURN_RATE * delta)
        joints[0] += velocities[0] * delta

    # Rest of the segments
    for i in range(1, SEGMENT_COUNT):
        var to_prev = (joints[i - 1] - joints[i]).normalized()
        # Gently steer toward the segment ahead
        velocities[i] = velocities[i].lerp(to_prev * SPEED, TURN_RATE * delta)
        joints[i] += velocities[i] * delta

        # Optional: maintain bone length constraint (soft correction)
        var diff = joints[i] - joints[i - 1]
        var dist = diff.length()
        if dist > BONE_LENGTH * 1.5:
            joints[i] = joints[i - 1] + diff.normalized() * BONE_LENGTH

func _draw() -> void:
    for i in range(SEGMENT_COUNT - 1):
        draw_line(joints[i], joints[i + 1], Color.DARK_ORANGE, 3.0)
