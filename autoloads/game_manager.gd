extends Node

var active_grid: GridSystem
var player: Player


func _ready() -> void:
	Conductor.beat_hit.connect(_on_beat_hit_turn_manager)


func _on_beat_hit_turn_manager(beat: Conductor.BeatInfo, measure: int) -> void:
	# Logical turn execution order:
	get_tree().call_group(&"player", &"execute_turn", beat, measure)
	get_tree().call_group(&"trap",   &"execute_turn", beat, measure)
	get_tree().call_group(&"enemy",  &"execute_turn", beat, measure)


# Tempo em segundos até o mouse sumir
var mouse_timer: float = 1.0
var inactive_time: float = 0.0

func _input(event):
	if event is InputEventMouseMotion:
		inactive_time = 0.0
		
		if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _process(delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		inactive_time += delta
		
		if inactive_time >= mouse_timer:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
