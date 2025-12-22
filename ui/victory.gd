extends ColorRect

var SM = SceneManager


func _on_voltar_button_pressed() -> void:
	SM.change_scene_to(SM.MainScene.MENU)


func win() -> void:
	Conductor.stop()
	self.visible = true
