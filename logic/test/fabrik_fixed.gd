extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 64.0
const HEAD_DAMPING := 0.4

var joints: Array[Vector2] = []
var target_position: Vector2 = Vector2.ZERO
var root_position: Vector2

func _ready() -> void:
    root_position = Vector2(300, 300)  # Or wherever you want it fixed
    for i in range(SEGMENT_COUNT):
        joints.append(root_position + Vector2(i * BONE_LENGTH, 0))


func _process(delta: float) -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        target_position = get_global_mouse_position()
        move_snake_with_fixed_root(target_position)

    queue_redraw()


func move_snake_with_fixed_root(target: Vector2) -> void:
    # Step 1: Move head toward target
    joints[SEGMENT_COUNT - 1] = joints[SEGMENT_COUNT - 1].lerp(target, HEAD_DAMPING)

    # Step 2: Backward pass (from head to root)
    for i in range(SEGMENT_COUNT - 2, -1, -1):
        var direction = (joints[i] - joints[i + 1]).normalized()
        joints[i] = joints[i + 1] + direction * BONE_LENGTH

    # Step 3: Forward pass (from root)
    joints[0] = root_position  # Pin the root
    for i in range(1, SEGMENT_COUNT):
        var direction = (joints[i] - joints[i - 1]).normalized()
        joints[i] = joints[i - 1] + direction * BONE_LENGTH


func _draw() -> void:
    for i in range(SEGMENT_COUNT - 1):
        draw_line(joints[i], joints[i + 1], Color.ORANGE_RED, 2.0)