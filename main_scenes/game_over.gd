extends ColorRect

var SM = SceneManager

func _ready() -> void:
	GameManager.player.died.connect(_on_player_died)


func _on_reiniciar_button_pressed() -> void:
	get_parent().get_parent().restart_level()


func _on_voltar_button_pressed() -> void:
	SM.change_scene_to(SM.MainScene.MENU)

func _on_player_died(player) -> void:
	print("Game Over!")
	Conductor.stop()
	self.visible = true
