extends Node

var hover_sfx = preload("res://audio/UI/hover.wav")
var click_sfx = preload("res://audio/UI/click 2.wav")
var confirm_sfx = preload("res://audio/UI/confirm_3.wav")
var cancel_sfx = preload("res://audio/UI/cancel.wav")
var error_sfx = preload("res://audio/UI/error.wav")
var delete_sfx = preload("res://audio/SFX/egg_crack.wav")
var plate_sfx = preload("res://audio/SFX/plate.wav")
var veg_sfx = preload("res://audio/SFX/pick up vegetables.wav")
var close_menu_sfx = preload("res://audio/UI/close menu 1.wav")
var mop_sfx = preload("res://audio/SFX/mop.wav")
var sponge_sfx = preload("res://audio/SFX/sponge cleaning.wav")
var cutting_meat_sfx = preload("res://audio/SFX/cutting meat.wav")
var cutting_vegetables_sfx = preload("res://audio/SFX/cutting vegetables.wav")
var notification_sfx = preload("res://audio/UI/notification.wav")
var frying_long_sfx = preload("res://audio/SFX/frying_long.wav")
var frying_short_sfx = preload("res://audio/SFX/frying_short.wav")
var water_boiling_sfx = preload("res://audio/SFX/water boiling_short.wav")
var water_flow_sfx = preload("res://audio/SFX/water flow.wav")
var salt_sfx = preload("res://audio/SFX/salt.wav")
var refrigerator_sfx = preload("res://audio/SFX/refrigerator.wav")
var track_menu = preload("res://audio/Music/Cozy Loop 1 - Family Time.wav")
var track_gameplay = preload("res://audio/Music/Cozy Loop 2 - Happy-Tyzer_LONG.wav")
var track_intro = preload("res://audio/Music/VNV2.wav")
var track_clients = preload("res://audio/Music/sad customer_v2.wav")
var track_cooking_tutorial = preload("res://audio/Music/Cozy Loop 3 - Conversation.wav")
var track_night = preload("res://audio/Music/Cozy Loop 4 - Good Night.wav")

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#func play_sfx(stream: AudioStream) -> void:
	#sfx_player.stream = stream
	#sfx_player.play()


func play_sfx(stream: AudioStream) -> void:
	var temp_player = AudioStreamPlayer.new()
	temp_player.stream = stream
	add_child(temp_player)
	temp_player.play()
	temp_player.finished.connect(temp_player.queue_free)


func stop_all_sfx() -> void:
	for child in get_children():
		if child is AudioStreamPlayer and child != music_player:
			child.queue_free()


func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.play()
