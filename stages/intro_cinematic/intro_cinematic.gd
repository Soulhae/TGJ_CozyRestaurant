extends CanvasLayer

signal intro_finished

const MAIN_MENU_SCENE: PackedScene = preload("res://stages/main_menu/main_menu.tscn")
const SKIP_DELAY: float = 0.15

@export_multiline var mateo_phrases: Array[String]
@export var char_speed: float = 15.0

var current_index: int = 0
var tween: Tween
var skip_cooldown: float = 0.0

@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	label.text = ""
	label.modulate.a = 0
	AudioManager.play_music(AudioManager.track_intro)
	play_next_phrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skip_cooldown > 0.0:
		skip_cooldown -= delta
	
	if Input.is_action_pressed("QTE") and skip_cooldown <= 0.0:
		skip_cooldown = SKIP_DELAY
		advance_dialogue()


#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("QTE"):
		#get_viewport().set_input_as_handled()
		#advance_dialogue()


func advance_dialogue() -> void:
	if tween and tween.is_running():
		tween.kill()
		label.visible_ratio = 1.0
		label.modulate.a = 1.0
	else:
		current_index += 1
		play_next_phrase()


func play_next_phrase():
	if current_index == mateo_phrases.size():
		intro_finished.emit()
		get_tree().change_scene_to_packed(MAIN_MENU_SCENE)
		return
	
	if tween and tween.is_running():
		tween.kill()
	
	label.text = mateo_phrases[current_index].strip_edges()
	label.visible_ratio = 0
	var total_chars: int = label.get_total_character_count()
	var duration: float = total_chars / char_speed
	
	tween = create_tween()
	tween.tween_property(label, "modulate:a", 1, 0.25)
	tween.tween_property(label, "visible_ratio", 1, duration)
	tween.tween_interval(1)
	tween.tween_property(label, "modulate:a", 0, 1.5)
	tween.tween_callback(_on_phrase_finished)


func _on_phrase_finished() -> void:
	current_index += 1
	play_next_phrase()
