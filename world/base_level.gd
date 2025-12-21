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
	_setup_audio()
	_setup_connections()
	_setup_ui()
	print(self.scene_file_path)


func _setup_audio() -> void:
	Conductor.load_song(music)
	Conductor.start_song()


func _setup_connections() -> void:
	if player:
		player.died.connect(_on_player_died)
	
	# Se o GameOver tiver um sinal de reiniciar, conecte aqui também
	# Exemplo: game_over_ui.restart_requested.connect(restart_level)


func _setup_ui() -> void:
	if game_over_ui: game_over_ui.visible = false
	if pause_menu: pause_menu.visible = false


func _on_player_died(_dead_entity: GridEntity) -> void:
	print("Game Over!")
	Conductor.stop()
	if game_over_ui:
		game_over_ui.visible = true


# Função pública para ser chamada pelos botões de UI
func restart_level() -> void:
	get_tree().change_scene_to_file(self.scene_file_path)


func go_to_next_level() -> void:
	if next_level_scene:
		get_tree().change_scene_to_file(next_level_scene)
