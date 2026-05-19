# Design Ref: §2.3 Autoload, Plan §11.2 M5 step 2.
# Provides BGM + SFX bus volumes + per-stream playback helpers.
# Actual AudioStream assets land in assets/audio/ later — manager is asset-agnostic.
extends Node

const SECTION := "settings"

# Bus names (default Master always exists; we add Music/SFX in _ready if missing).
const BUS_MASTER := &"Master"
const BUS_MUSIC := &"Music"
const BUS_SFX := &"SFX"

@onready var _music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 6

func _ready() -> void:
	_ensure_buses()
	add_child(_music_player)
	_music_player.bus = String(BUS_MUSIC)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = String(BUS_SFX)
		add_child(p)
		_sfx_players.append(p)
	apply_saved_volumes()

func _ensure_buses() -> void:
	# Add Music + SFX buses programmatically (no .tres bus layout file needed).
	if AudioServer.get_bus_index(BUS_MUSIC) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_MUSIC)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, BUS_MASTER)
	if AudioServer.get_bus_index(BUS_SFX) == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS_SFX)
		AudioServer.set_bus_send(AudioServer.bus_count - 1, BUS_MASTER)

# === Volume API (0.0 ~ 1.0 linear, mapped to dB) ===

func set_volume(bus: StringName, linear: float) -> void:
	linear = clamp(linear, 0.0, 1.0)
	var idx := AudioServer.get_bus_index(bus)
	if idx == -1:
		return
	var db := linear_to_db(linear) if linear > 0.0 else -80.0
	AudioServer.set_bus_volume_db(idx, db)
	SaveManager.set_value_float(SECTION, "vol_" + String(bus).to_lower(), linear)

func get_volume(bus: StringName) -> float:
	return SaveManager.get_value_float(SECTION, "vol_" + String(bus).to_lower(), 1.0)

func apply_saved_volumes() -> void:
	set_volume(BUS_MASTER, get_volume(BUS_MASTER))
	set_volume(BUS_MUSIC, get_volume(BUS_MUSIC))
	set_volume(BUS_SFX, get_volume(BUS_SFX))

# === Playback ===

func play_bgm(stream: AudioStream) -> void:
	if stream == null:
		_music_player.stop()
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()

func stop_bgm() -> void:
	_music_player.stop()

func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return
	# All busy — interrupt the first
	_sfx_players[0].stream = stream
	_sfx_players[0].play()
