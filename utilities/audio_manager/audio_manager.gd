extends Node

var hover_sfx = preload("res://audio/UI/hover.wav")
var click_sfx = preload("res://audio/UI/click 2.wav")
var confirm_sfx = preload("res://audio/UI/confirm_3.wav")
var cancel_sfx = preload("res://audio/UI/cancel.wav")
var error_sfx = preload("res://audio/UI/error.wav")
var sponge_sfx = preload("res://audio/SFX/sponge cleaning.wav")
var water_flow_sfx = preload("res://audio/SFX/water flow.wav")
var track_menu = preload("res://audio/Music/Cozy Loop 1 - Family Time.wav")
var track_gameplay = preload("res://audio/Music/Cozy Loop 2 - Happy-Tyzer_LONG.wav")
var track_intro = preload("res://stages/main_menu/Intro VN.wav")

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()


func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.play()
