# Design Ref: §5.1 Settings, Plan §11.2 M5 step 2-3.
# Volume sliders (Master/Music/SFX) + fullscreen toggle. SaveManager persists.
extends CanvasLayer

signal closed

@onready var _master_slider: HSlider = $Center/Panel/Margin/Layout/MasterRow/Slider
@onready var _music_slider: HSlider = $Center/Panel/Margin/Layout/MusicRow/Slider
@onready var _sfx_slider: HSlider = $Center/Panel/Margin/Layout/SfxRow/Slider
@onready var _master_value: Label = $Center/Panel/Margin/Layout/MasterRow/Value
@onready var _music_value: Label = $Center/Panel/Margin/Layout/MusicRow/Value
@onready var _sfx_value: Label = $Center/Panel/Margin/Layout/SfxRow/Value
@onready var _fullscreen_check: CheckButton = $Center/Panel/Margin/Layout/FullscreenRow/Check
@onready var _close_button: Button = $Center/Panel/Margin/Layout/Footer/CloseButton

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_master_slider.value_changed.connect(_on_master)
	_music_slider.value_changed.connect(_on_music)
	_sfx_slider.value_changed.connect(_on_sfx)
	_fullscreen_check.toggled.connect(_on_fullscreen)
	_close_button.pressed.connect(_on_close)

func open() -> void:
	_refresh()
	show()

func _refresh() -> void:
	_master_slider.value = AudioManager.get_volume(AudioManager.BUS_MASTER)
	_music_slider.value = AudioManager.get_volume(AudioManager.BUS_MUSIC)
	_sfx_slider.value = AudioManager.get_volume(AudioManager.BUS_SFX)
	_update_value_labels()
	var is_full := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	_fullscreen_check.set_pressed_no_signal(is_full)

func _update_value_labels() -> void:
	_master_value.text = "%d%%" % int(_master_slider.value * 100.0)
	_music_value.text = "%d%%" % int(_music_slider.value * 100.0)
	_sfx_value.text = "%d%%" % int(_sfx_slider.value * 100.0)

func _on_master(v: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MASTER, v)
	_update_value_labels()

func _on_music(v: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_MUSIC, v)
	_update_value_labels()

func _on_sfx(v: float) -> void:
	AudioManager.set_volume(AudioManager.BUS_SFX, v)
	_update_value_labels()

func _on_fullscreen(pressed: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if pressed else DisplayServer.WINDOW_MODE_WINDOWED)
	SaveManager.set_value_bool("settings", "fullscreen", pressed)

func _on_close() -> void:
	hide()
	closed.emit()
