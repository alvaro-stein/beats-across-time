extends CanvasLayer

@onready var pause_panel := $CenterContainer/PausePanel
@onready var options_panel := $CenterContainer/OptionsPanel
@onready var master_slider: HSlider = $CenterContainer/OptionsPanel/AudioContainer/MasterRow/MasterSlider
@onready var hit_window_option: OptionButton = $CenterContainer/OptionsPanel/HitWindowRow/HitWindowOption
@onready var resolution_option: OptionButton = $CenterContainer/OptionsPanel/ResolutionRow/ResolutionOption
@onready var fullscreen_toggle: CheckButton = $CenterContainer/OptionsPanel/FullscreenRow/FullscreenToggle

func _ready() -> void:
	options_panel.visible = false
	_master_init()
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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if visible:
			_on_iniciar_button_pressed()
		else:
			show_menu()


func show_menu() -> void:
	visible = true
	Conductor.stream_paused = true
	pause_panel.visible = true
	options_panel.visible = false

func _on_iniciar_button_pressed() -> void:
	Conductor.stream_paused = false
	visible = false

func _on_opcoes_button_pressed() -> void:
	pause_panel.visible = false
	options_panel.visible = true

func _on_reiniciar_button_pressed() -> void:
	get_parent().get_parent().restart_level()


func _on_sair_button_pressed() -> void:
	Conductor.stream_paused = false
	Conductor.stop()
	SceneManager.change_scene_to(SceneManager.MainScene.MENU)

func _db_to_slider(db: float) -> float:
	return db_to_linear(db)

func _slider_to_db(value: float) -> float:
	var linear = max(value, 0.001)
	return linear_to_db(linear)

func _master_init() -> void:
	var idx = AudioServer.get_bus_index(&"Master")
	if idx >= 0:
		master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(idx))

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

func _on_back_button_pressed() -> void:
	options_panel.visible = false
	pause_panel.visible = true

func _window_mode_init() -> void:
	var mode := DisplayServer.window_get_mode()
	var fullscreen := mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	fullscreen_toggle.button_pressed = fullscreen
	resolution_option.disabled = fullscreen
