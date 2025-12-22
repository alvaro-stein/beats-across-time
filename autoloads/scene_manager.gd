extends Node

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect


enum MainScene {
	MENU,
	LEVEL1,
	CAVE,
	LEVEL2,
	BOSS,
	TUTORIAL
}

const MAIN_SCENES_UIDS: Dictionary = {
	MainScene.MENU: "uid://lo2gkq41mho5",
	MainScene.LEVEL1: "uid://brk3mycpdxa6w",
	MainScene.CAVE: "uid://dscddwibve1vf",
	MainScene.LEVEL2: "uid://dkfna8rdw6dsc",
	MainScene.BOSS: "uid://dmi6cyua4k65w",
	MainScene.TUTORIAL: "uid://b5jra0qp4euh7"
}


func _ready() -> void:
	# ATTENTION: call_deferred is necessary to load the initial scene safely only after the bootloader scene has been properly initialized.
	# INFO: Change the initial scene here
	get_tree().call_deferred("change_scene_to_file", MAIN_SCENES_UIDS[MainScene.MENU])


func change_scene_to(next_scene: MainScene) -> void:
	await fade_in()
	
	get_tree().change_scene_to_file(MAIN_SCENES_UIDS[next_scene])
	await get_tree().scene_changed
	
	fade_out()


func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(color_rect.material, "shader_parameter/progress", 24.0, 0.5)
	await tween.finished


func fade_out() -> void:
	var tween = create_tween()
	color_rect.material.set_shader_parameter("invert", false)
	color_rect.material.set_shader_parameter("progress", 0.0)
	tween.tween_property(color_rect.material, "shader_parameter/progress", 24.0, 0.5)
	
	await tween.finished
	color_rect.material.set_shader_parameter("invert", true)
	color_rect.material.set_shader_parameter("progress", 0.0)

func restart_level(level: BaseLevel) -> void:
	await fade_in()
	
	get_tree().change_scene_to_file(level.scene_file_path)
	await get_tree().scene_changed
	
	fade_out()
