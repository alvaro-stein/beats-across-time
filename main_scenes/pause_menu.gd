extends CanvasLayer

func show_menu() -> void:
	visible = true
	Conductor.stream_paused = true

func _on_iniciar_button_pressed() -> void:
	Conductor.stream_paused = false
	visible = false

func _on_opcoes_button_pressed() -> void:
	Conductor.stream_paused = false
	SceneManager.change_scene_to(SceneManager.MainScene.MENU)

func _on_sair_button_pressed() -> void:
	Conductor.stream_paused = false
	SceneManager.change_scene_to(SceneManager.MainScene.MENU)
