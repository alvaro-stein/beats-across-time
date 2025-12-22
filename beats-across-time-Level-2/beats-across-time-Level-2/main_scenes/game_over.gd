extends ColorRect

var SM = SceneManager

func _on_reiniciar_button_pressed() -> void:
	if get_parent().name == "Level1":
		SM.change_scene_to(SM.MainScene.LEVEL1)
	else:
		SM.change_scene_to(SM.MainScene.LEVEL2)


func _on_voltar_button_pressed() -> void:
	SM.change_scene_to(SM.MainScene.MENU)
