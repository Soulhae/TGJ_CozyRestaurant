extends CanvasLayer

signal intro_finished

@export_multiline var mateo_phrases: Array[String]
@export var char_speed: float = 15.0

var current_index: int = 0
var tween: Tween

@onready var label: Label = %Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	label.modulate.a = 0
	play_next_phrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("QTE"):
		advance_dialogue()


func advance_dialogue() -> void:
	if tween and tween.is_running():
		tween.kill()
		label.visible_ratio = 1.0
	else:
		current_index += 1
		play_next_phrase()


func play_next_phrase():
	if current_index == mateo_phrases.size():
		intro_finished.emit()
		queue_free()
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
	tween.tween_callback(play_next_phrase)
