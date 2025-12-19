extends CanvasLayer

@onready var pause_panel := $CenterContainer/PausePanel
@onready var options_panel := $CenterContainer/OptionsPanel
@onready var master_slider: HSlider = $CenterContainer/OptionsPanel/AudioContainer/MasterRow/MasterSlider
@onready var hit_window_option: OptionButton = $CenterContainer/OptionsPanel/HitWindowRow/HitWindowOption

func _ready() -> void:
	options_panel.visible = false
	# Initialize audio sliders from current bus volumes if available
	_master_init()
	# Populate hit window options
	hit_window_option.clear()
	hit_window_option.add_item("Difícil")
	hit_window_option.add_item("Normal")
	hit_window_option.add_item("Fácil")
	# Select current based on Settings
	var early = Settings.hit_window_early_sec
	var late = Settings.hit_window_late_sec
	var idx = 1 # Normal default
	if early <= 0.08 and late <= 0.06:
		idx = 0
	elif early >= 0.19 and late >= 0.14:
		idx = 2
	hit_window_option.select(idx)

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

func _on_back_button_pressed() -> void:
	options_panel.visible = false
	pause_panel.visible = true

func _on_sair_button_pressed() -> void:
	# Stop music entirely when returning to main menu
	Conductor.stream_paused = false
	Conductor.stop()
	SceneManager.change_scene_to(SceneManager.MainScene.MENU)

func _bus_index(name: String) -> int:
	return AudioServer.get_bus_index(name)

func _db_to_slider(db: float) -> float:
	return db_to_linear(db)

func _slider_to_db(value: float) -> float:
	var linear = max(value, 0.001)
	return linear_to_db(linear)

func _master_init() -> void:
	var idx = _bus_index("Master")
	if idx >= 0:
		master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(idx))

func _on_master_slider_value_changed(value: float) -> void:
	var idx = _bus_index("Master")
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
