extends CanvasLayer

@onready var pause_panel := $CenterContainer/PausePanel
@onready var options_panel := $CenterContainer/OptionsPanel
@onready var master_slider: HSlider = $CenterContainer/OptionsPanel/AudioContainer/MasterRow/MasterSlider
@onready var music_slider: HSlider = $CenterContainer/OptionsPanel/AudioContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/OptionsPanel/AudioContainer/SfxRow/SfxSlider

func _ready() -> void:
	options_panel.visible = false
	# Initialize audio sliders from current bus volumes if available
	_master_init()
	_music_init()
	_sfx_init()

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

func _music_init() -> void:
	var idx = _bus_index("Music")
	if idx >= 0:
		music_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(idx))

func _sfx_init() -> void:
	var idx = _bus_index("SFX")
	if idx >= 0:
		sfx_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(idx))

func _on_master_slider_value_changed(value: float) -> void:
	var idx = _bus_index("Master")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))

func _on_music_slider_value_changed(value: float) -> void:
	var idx = _bus_index("Music")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	var idx = _bus_index("SFX")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, _slider_to_db(value))
