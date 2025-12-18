extends Node2D

@onready var song_time_label: Label = $debug/HBoxContainer/VBoxContainer/SongTimeLabel
@onready var label: Label = $debug/HBoxContainer/VBoxContainer/Label
@onready var error_label: Label = $debug/HBoxContainer/VBoxContainer/ErrorLabel
@onready var color_rect: ColorRect = $ColorRect
@onready var player_hp: Label = $debug/HBoxContainer/VBoxContainer2/PlayerHP
@onready var player: Player = $Player
@onready var pause_menu: CanvasLayer = $PauseMenu

const GRAY = Color.DIM_GRAY
const GREEN = Color.DARK_GREEN
const RED = Color.DARK_RED

func _ready() -> void:
	Conductor.beat_hit.connect(_on_beat_hit)
	InputJudge.action_judged.connect(_on_action_judged)
	player_hp.text = "PlayerHP = %d/%d" % [ player.current_hp, player.max_hp ]
	
	color_rect.color = Color(GRAY, 0)
	
	var song_data = SongDB.get_song_data(SongDB.Song.IDADE_DAS_PEDRAS)
	Conductor.load_song(song_data)
	Conductor.start_song()

func _process(delta: float) -> void:
	song_time_label.text = "song_time = %.3f" % Conductor.song_time

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_menu.visible:
			pause_menu._on_iniciar_button_pressed()
		else:
			pause_menu.show_menu()

func _on_beat_hit(beat: Conductor.BeatInfo, measure_pos) -> void:
	label.text = "turn time = %.3f\nlast_beat.pos = %d\nmeasure_pos = %d" % [ Conductor.song_time, beat.pos, measure_pos ]
	await get_tree().create_timer(0.1).timeout
	player_hp.text = "PlayerHP = %d/%d" % [ player.current_hp, player.max_hp ]

func _on_action_judged(action: StringName, judgement: InputJudge.Judgment, error_ms: int) -> void:
	if action == &"up" or action == &"down" or action == &"left" or action == &"right" or action == &"space":
		if judgement == InputJudge.Judgment.HIT:
			color_rect.color = Color(GREEN, 1)
		else:
			color_rect.color = Color(RED, 1)
		error_label.text = "error_ms = %d" % error_ms
		
		var tween = create_tween()
		tween.tween_property(color_rect, "color", Color(GRAY, 0), 0.5)
