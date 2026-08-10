extends Control

const GAME_SCENE: PackedScene = preload("res://stages/mateo_room/mateo_room.tscn")

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var controls_button: Button = %ControlsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_button: Button = %ExitButton
@onready var settings_view: ColorRect = %SettingsView
@onready var controls_view: ColorRect = %ControlsView
@onready var credits_view: ColorRect = %CreditsView
@onready var settings_back_button: Button = $SettingsView/BackButton
@onready var controls_back_button: Button = $ControlsView/BackButton
@onready var credits_back_button: Button = $CreditsView/BackButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(AudioManager.track_menu)
	settings_view.visible = false
	controls_view.visible = false
	credits_view.visible = false
	
	settings_back_button.pressed.connect(_on_settings_back_pressed)
	controls_back_button.pressed.connect(_on_controls_back_pressed)
	credits_back_button.pressed.connect(_on_credits_back_pressed)
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	start_button.release_focus()
	await get_tree().create_timer(1.0).timeout
	start_button.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_SCENE)


func _on_settings_pressed() -> void:
	settings_view.visible = true
	settings_back_button.grab_focus()


func _on_settings_back_pressed() -> void:
	settings_view.visible = false
	start_button.grab_focus()


func _on_controls_pressed() -> void:
	controls_view.visible = true
	controls_back_button.grab_focus()


func _on_controls_back_pressed() -> void:
	controls_view.visible = false
	start_button.grab_focus()

func _on_credits_pressed() -> void:
	credits_view.visible = true
	credits_back_button.grab_focus()


func _on_credits_back_pressed() -> void:
	credits_view.visible = false
	start_button.grab_focus()

func _on_exit_pressed() -> void:
	get_tree().quit()
