class_name BaseLevel
extends Node2D

signal win

@export_group("Level Settings")
@export var music: SongData
@export var next_level_scene: String # UID ou Path da próxima fase

@onready var player: Player = $Player
@onready var game_over_ui: Control = $GameOver
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var victory: ColorRect = $HUD/Victory


func _ready() -> void:
	assert(music, "Nenhuma música foi adicionada no export do inspetor para este Level")
	win.connect(_on_win)
	Conductor.load_song(music)
	Conductor.start_song()


# Função pública para ser chamada pelos botões de UI
func restart_level() -> void:
	SceneManager.restart_level(self)

func _on_win():
	victory.win()
