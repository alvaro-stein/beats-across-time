extends Node

# Default hit window constants
const DEFAULT_HIT_WINDOW_EARLY_SEC: float = 0.150
const DEFAULT_HIT_WINDOW_LATE_SEC: float = 0.100 ## Equals TURN_DELAY_SEC
const TURN_DELAY_SEC = DEFAULT_HIT_WINDOW_LATE_SEC ## Equals HIT_WINDOW_LATE_SEC

# Runtime-configurable hit window (used by InputJudge)
var hit_window_early_sec: float = DEFAULT_HIT_WINDOW_EARLY_SEC
var hit_window_late_sec: float = DEFAULT_HIT_WINDOW_LATE_SEC

func set_hit_window_mode(mode: String) -> void:
	# Modes: "estrito", "normal", "facil"
	match mode:
		"estrito":
			hit_window_early_sec = 0.075
			hit_window_late_sec = 0.050
		"facil":
			hit_window_early_sec = 0.200
			hit_window_late_sec = 0.150
		_:
			# normal/default
			hit_window_early_sec = DEFAULT_HIT_WINDOW_EARLY_SEC
			hit_window_late_sec = DEFAULT_HIT_WINDOW_LATE_SEC
