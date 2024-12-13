extends Node

const LEFT := -1
const RIGHT := 1

var gravity := 0.0
var gravity_cap := 2000.0

func _ready() -> void:
	gravity = 1000
