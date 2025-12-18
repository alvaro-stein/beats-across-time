extends Resource
class_name SongData

## O arquivo de áudio (ex: .ogg ou .mp3 ou .wav)
@export var audio_stream: AudioStream
@export var name: String = "Untitled"

@export var bpm: int = 60
@export var measure: int = 4  # Para compasso 4/4
@export var initial_offset: float = 0.0 # Atraso inicial em segundos antes do primeiro beat
@export var length_in_beats: int = 0
