extends Node2D

func _ready() -> void:
	var song_data = SongDB.get_song_data(SongDB.Song.IDADE_DAS_PEDRAS)
	Conductor.load_song(song_data)
	Conductor.start_song()
