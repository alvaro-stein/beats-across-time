extends Node

enum Song {
	TEST_SONG,
	IDADE_DAS_PEDRAS
}

const SONGS_UIDS: Dictionary = {
	Song.TEST_SONG: "uid://bkvw7rghnut5a",
	Song.IDADE_DAS_PEDRAS: "uid://wexxdeoax8r8"
}

func get_song_data(song: Song) -> SongData:
	return load(SONGS_UIDS[song])
