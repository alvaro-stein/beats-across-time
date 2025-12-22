extends Node2D

@onready var player: Player = $Player
@onready var game_over: ColorRect = $GameOver


func _ready() -> void:
	player.died.connect(_on_player_died)
	
	var song_data = SongDB.get_song_data(SongDB.Song.IDADE_DAS_PEDRAS)
	Conductor.load_song(song_data)
	Conductor.start_song()

func _on_player_died(player: Player):
	game_over.visible = true
	Conductor.stop()
