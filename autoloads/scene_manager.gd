extends Node

enum MainScene {
	MENU,
	GAME_TEST,
	LEVEL1,
	LEVEL2,
	BOSS
}

const MAIN_SCENES_UIDS: Dictionary = {
	MainScene.MENU: "uid://lo2gkq41mho5",
	MainScene.GAME_TEST: "uid://cebb54jsd0lk8",
	MainScene.LEVEL1: "uid://brk3mycpdxa6w",
	MainScene.LEVEL2: "uid://dkfna8rdw6dsc",
	MainScene.BOSS: "uid://dmi6cyua4k65w"
}


func _ready() -> void:
	# ATTENTION: call_deferred is necessary to load the initial scene safely only after the bootloader scene has been properly initialized.
	# INFO: Change the initial scene here    vvv
	self.call_deferred("change_scene_to", MainScene.MENU)


func change_scene_to(next_scene: MainScene) -> void:
	# TODO: Add transition scene animation
	get_tree().change_scene_to_file(MAIN_SCENES_UIDS[next_scene])
