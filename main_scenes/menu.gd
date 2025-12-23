extends Node

@onready var center_container: CenterContainer = $CenterContainer
@onready var main_panel: VBoxContainer = $MainPanel
@onready var options_panel: VBoxContainer = $CenterContainer/PanelContainer/OptionsPanel
@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer

@onready var master_slider: HSlider = $CenterContainer/PanelContainer/OptionsPanel/AudioContainer/Master/MasterSlider
@onready var music_slider: HSlider = $CenterContainer/PanelContainer/OptionsPanel/AudioContainer/Music/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/PanelContainer/OptionsPanel/AudioContainer/Sfx/SfxSlider

@onready var hit_window_option: OptionButton = $CenterContainer/PanelContainer/OptionsPanel/HitWindowRow/HitWindowOption
@onready var resolution_option: OptionButton = $CenterContainer/PanelContainer/OptionsPanel/ResolutionRow/ResolutionOption
@onready var fullscreen_toggle: CheckButton = $CenterContainer/PanelContainer/OptionsPanel/FullscreenRow/FullscreenToggle

@onready var camera_2d: Camera2D = $Camera2D
@onready var tutorial: Tutorial = $Tutorial
@onready var jogar_button: Button = $MainPanel/Jogar
@onready var title_label: Label = $CenterContainer/TitleLabel


func _ready() -> void:
	panel_container.visible = false
	_sound_sliders_init()
	hit_window_option.clear()
	hit_window_option.add_item("Difícil")
	hit_window_option.add_item("Normal")
	hit_window_option.add_item("Fácil")
	var early = Settings.hit_window_early_sec
	var late = Settings.hit_window_late_sec
	var idx = 1 # Normal default
	if early <= 0.08 and late <= 0.06:
		idx = 0
	elif early >= 0.19 and late >= 0.14:
		idx = 2
	hit_window_option.select(idx)
	_resolution_init()
	_window_mode_init()


func _on_jogar_pressed() -> void:
	for button in main_panel.get_children().filter(func(c): return c is Button):
		button.disabled = true
	var tween1 = create_tween()
	var tween2 = create_tween()
	tween1.tween_property(camera_2d, "zoom", Vector2(1.0, 1.0), 5.0).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(center_container, "modulate:a", 0.0, 1.5)
	
	await get_tree().create_timer(3.5).timeout
	tutorial.start_tutorial()
	
	await tween1.finished
	center_container.queue_free()
	camera_2d.queue_free()


func _on_level_1_button_pressed() -> void:
	SceneManager.change_scene_to(SceneManager.MainScene.LEVEL1)

func _on_level_2_button_pressed() -> void:
	SceneManager.change_scene_to(SceneManager.MainScene.LEVEL2)

func _on_boss_button_pressed() -> void:
	SceneManager.change_scene_to(SceneManager.MainScene.BOSS)

func _on_caverna_button_pressed() -> void:
	SceneManager.change_scene_to(SceneManager.MainScene.CAVE)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	main_panel.visible = false
	title_label.visible = false
	panel_container.visible = true

func _on_back_button_pressed() -> void:
	panel_container.visible = false
	title_label.visible = true
	main_panel.visible = true


func _slider_to_db(value: float) -> float:
	var linear = max(value, 0.001)
	return linear_to_db(linear)


func _sound_sliders_init() -> void:
	var idx = AudioServer.get_bus_index(&"Master")
	if idx >= 0:
		master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
	
	idx = AudioServer.get_bus_index(&"Music")
	if idx >= 0:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))
	
	idx = AudioServer.get_bus_index(&"Sfx")
	if idx >= 0:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(idx))


func _on_master_slider_value_changed(value: float) -> void:
	var idx = AudioServer.get_bus_index(&"Master")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))


func _on_music_slider_value_changed(value: float) -> void:
	var idx = AudioServer.get_bus_index(&"Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	var idx = AudioServer.get_bus_index(&"Sfx")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))


func _on_hit_window_option_selected(index: int) -> void:
	match index:
		0:
			Settings.set_hit_window_mode("estrito")
		1:
			Settings.set_hit_window_mode("normal")
		2:
			Settings.set_hit_window_mode("facil")


func _resolution_presets() -> Array[Vector2i]:
	return [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]


func _resolution_init() -> void:
	resolution_option.clear()
	var current_size: Vector2i = DisplayServer.window_get_size()
	var best_idx := 0
	var best_diff := INF
	for i in _resolution_presets().size():
		var res = _resolution_presets()[i]
		resolution_option.add_item("%dx%d" % [res.x, res.y])
		var diff = abs(res.x - current_size.x) + abs(res.y - current_size.y)
		if diff < best_diff:
			best_diff = diff
			best_idx = i
	resolution_option.select(best_idx)


func _on_resolution_option_selected(index: int) -> void:
	if resolution_option.disabled:
		return
	_apply_resolution_index(index)


func _apply_resolution_index(index: int) -> void:
	var presets = _resolution_presets()
	if index >= 0 and index < presets.size():
		DisplayServer.window_set_size(presets[index])


func _on_fullscreen_toggle_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		resolution_option.disabled = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		resolution_option.disabled = false
		_apply_resolution_index(resolution_option.selected)


func _window_mode_init() -> void:
	var mode := DisplayServer.window_get_mode()
	var fullscreen := mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	fullscreen_toggle.button_pressed = fullscreen
	resolution_option.disabled = fullscreen
