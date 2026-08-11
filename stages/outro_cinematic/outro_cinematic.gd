extends CanvasLayer

signal outro_finished

const CREDITS_SCENE: PackedScene = preload("res://stages/main_menu/credits_view.tscn")
const SKIP_DELAY: float = 0.15

@export_multiline var mateo_phrases: Array[String]
@export var char_speed: float = 16

var current_index: int = 0
var tween: Tween
var skip_cooldown: float = 0.0

@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	label.text = ""
	label.modulate.a = 0
	AudioManager.play_music(AudioManager.track_clients)
	
	play_next_phrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if skip_cooldown > 0.0:
		skip_cooldown -= delta
	
	if Input.is_action_pressed("QTE") and skip_cooldown <= 0.0:
		skip_cooldown = SKIP_DELAY
		advance_dialogue()


func advance_dialogue() -> void:
	if tween and tween.is_running():
		tween.kill()
		if label.visible_ratio < 1.0:
			label.visible_ratio = 1.0
			label.modulate.a = 1.0
			
			tween = create_tween()
			var wait_time = 3.0 if current_index == mateo_phrases.size() - 1 else 1.0
			tween.tween_interval(wait_time)
			tween.tween_property(label, "modulate:a", 0, 0.75)
			tween.tween_callback(_on_phrase_finished)
		else:
			current_index += 1
			play_next_phrase()
	else:
		current_index += 1
		play_next_phrase()


func play_next_phrase():
	if current_index == mateo_phrases.size():
		outro_finished.emit()
		get_tree().change_scene_to_packed(CREDITS_SCENE)
		return
	
	if tween and tween.is_running():
		tween.kill()
	
	label.text = mateo_phrases[current_index].strip_edges()
	label.visible_ratio = 0
	var total_chars: int = label.get_total_character_count()
	var duration: float
	
	if current_index == mateo_phrases.size() - 1:
		duration = total_chars / 1.0
	else:
		duration = total_chars / char_speed
	
	tween = create_tween()
	tween.tween_property(label, "modulate:a", 1, 0.25)
	tween.tween_property(label, "visible_ratio", 1, duration)
	
	var wait_time = 1.0 if current_index == mateo_phrases.size() - 1 else 0.5
	tween.tween_interval(wait_time)
	
	tween.tween_property(label, "modulate:a", 0, 0.75)
	tween.tween_callback(_on_phrase_finished)


func _on_phrase_finished() -> void:
	current_index += 1
	play_next_phrase()
