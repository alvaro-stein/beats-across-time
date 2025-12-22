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
