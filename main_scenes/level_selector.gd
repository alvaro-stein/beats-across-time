extends CanvasLayer

signal level_selected(level: SceneManager.MainScene)
signal back_pressed

func _on_level_1_button_pressed() -> void:
	level_selected.emit(SceneManager.MainScene.LEVEL1)
	queue_free()

func _on_level_2_button_pressed() -> void:
	level_selected.emit(SceneManager.MainScene.CAVE)
	queue_free()

func _on_level_3_button_pressed() -> void:
	level_selected.emit(SceneManager.MainScene.LEVEL2)
	queue_free()

func _on_boss_button_pressed() -> void:
	level_selected.emit(SceneManager.MainScene.BOSS)
	queue_free()

func _on_back_button_pressed() -> void:
	back_pressed.emit()
	queue_free()
