class_name BaseLevel
extends Node2D

@export_group("Level Settings")
@export var music: SongData
@export var next_level_scene: String # UID ou Path da próxima fase

@onready var player: Player = $Player
@onready var game_over_ui: Control = $GameOver
@onready var pause_menu: CanvasLayer = $PauseMenu


func _ready() -> void:
	assert(music, "Nenhuma música foi adicionada no export do inspetor para este Level")
	
	Conductor.load_song(music)
	Conductor.start_song()


# Função pública para ser chamada pelos botões de UI
func restart_level() -> void:
	get_tree().change_scene_to_file(self.scene_file_path)
