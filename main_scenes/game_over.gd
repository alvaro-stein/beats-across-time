extends ColorRect

var SM = SceneManager

func _on_reiniciar_button_pressed() -> void:
	SM.change_scene_to(SM.MainScene.LEVEL1)


func _on_voltar_button_pressed() -> void:
	SM.change_scene_to(SM.MainScene.MENU)
