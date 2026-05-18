# Design Ref: §5.4 LevelUpUI card sub-component.
# Single Button containing icon/name/level/desc. Emits chosen() with its data.
extends Button

signal chosen(option: Dictionary)

@onready var _icon_rect: ColorRect = $Margin/Layout/IconRect
@onready var _name_label: Label = $Margin/Layout/NameLabel
@onready var _level_label: Label = $Margin/Layout/LevelLabel
@onready var _desc_label: Label = $Margin/Layout/DescLabel
@onready var _badge_label: Label = $Margin/Layout/Badge

var _option: Dictionary = {}

func _ready() -> void:
	pressed.connect(_on_pressed)

func set_option(option: Dictionary) -> void:
	_option = option
	var data: Resource = option.data
	if data is WeaponData:
		var w := data as WeaponData
		_name_label.text = w.display_name
		_desc_label.text = w.description
		_icon_rect.color = w.projectile_color
	elif data is PassiveData:
		var p := data as PassiveData
		_name_label.text = p.display_name
		_desc_label.text = p.description
		_icon_rect.color = p.color
	_level_label.text = "Lv. %d → %d" % [option.current_level, option.next_level]
	_badge_label.text = "NEW!" if option.is_new else "UPGRADE"
	_badge_label.modulate = (Color(1, 0.8, 0.3, 1) if option.is_new else Color(0.5, 0.9, 1, 1))

func _on_pressed() -> void:
	chosen.emit(_option)
