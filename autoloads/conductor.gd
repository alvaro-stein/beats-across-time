extends AudioStreamPlayer

signal beat_hit(beat: BeatInfo, measure_pos: int)
## Emitted when either the song starts or restarts
signal song_started

class BeatInfo:
	var pos: int = 0 ## The position of the beat ex: 0, 1, 2, 3...
	var time: float = 0.0 ## In seconds

var request_change_music: bool = true

var turn_delay_sec: float = Settings.hit_window_late_sec

var current_song: SongData = null
var bpm: int = 0 ## Beats per minute
var spb: float = 0.0 ## Seconds per beat (60 / bpm)
var measure: int = 4 ## Compasso
var initial_offset: float = 0.0
var song_length_in_beats: int = 0

var song_time: float = 0.0
var _song_beat_pos: int = 0
var last_beat: BeatInfo = BeatInfo.new()
var next_beat: BeatInfo = BeatInfo.new()
var _measure_pos: int = 0

var _is_awaiting_turn_delay: bool = false
var _delayed_emit_time: float

func _ready() -> void:
	# Adiciona o Conductor ao audio bus de música
	var music_bus = AudioServer.get_bus_index(&"Music")
	if music_bus >= 0:
		self.bus = &"Music"


func _process(_delta: float) -> void:
	if not playing:
		return
	
	var time = self.get_playback_position()
	time += AudioServer.get_time_since_last_mix()
	time -= AudioServer.get_output_latency()
	time -= initial_offset
	
	song_time = max(song_time, time)
	
	_song_beat_pos = floori(song_time / spb) + 1
	
	# if last beat, reset song
	if _song_beat_pos >= song_length_in_beats:
		start_song()
	
	if _song_beat_pos >= next_beat.pos: # Trigger beat
		last_beat.pos = next_beat.pos
		last_beat.time = next_beat.time
		next_beat.pos += 1
		next_beat.time = (next_beat.pos - 1) * spb
		_measure_pos = 1 if _measure_pos >= measure else _measure_pos + 1
		
		_is_awaiting_turn_delay = true
		_delayed_emit_time = last_beat.time + turn_delay_sec
	
	if _is_awaiting_turn_delay and song_time >= _delayed_emit_time:
		_is_awaiting_turn_delay = false
		self.beat_hit.emit(last_beat, _measure_pos)


func load_song(new_song: SongData) -> void:
	self.set_process(false)
	self.stop()
	# Set new data
	current_song = new_song
	self.stream = new_song.audio_stream
	self.bpm = new_song.bpm
	self.spb = 60.0 / bpm
	self.measure = new_song.measure
	self.initial_offset = new_song.initial_offset
	self.song_length_in_beats = new_song.length_in_beats


func start_song() -> void:
	self.song_started.emit()
	# Reset properties
	song_time = 0.0
	_song_beat_pos = 1
	last_beat.pos = 0
	last_beat.time = -1 * spb #sempre 0?
	next_beat.pos = 1
	next_beat.time = 0.0
	_measure_pos = 0
	self.set_process(true)
	self.play()
