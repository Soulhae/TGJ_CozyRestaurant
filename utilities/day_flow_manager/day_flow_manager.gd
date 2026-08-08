extends Node

signal phase_changed

enum DayPhase {
	MORNING_ORGANIZING,
	AFTERNOON_CLIENT,
	AFTERNOON_COOKING,
	NIGHT_CLEANING,
	NIGHT_SLEEPING,
}

var current_phase: DayPhase = DayPhase.MORNING_ORGANIZING
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func advance_to_afternoon() -> void:
	current_phase = DayPhase.AFTERNOON_CLIENT
	
	if tween and tween.is_running():
		tween.kill()
	
	var canvas_layer := CanvasLayer.new()
	get_tree().current_scene.add_child(canvas_layer)
	var color_rect := ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0
	canvas_layer.add_child(color_rect)
	
	tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1, 0.5)
	tween.tween_callback(_on_mid_transition_afternoon)
	tween.tween_interval(1)
	tween.tween_property(color_rect, "modulate:a", 0, 0.5)
	tween.tween_callback(canvas_layer.queue_free)


func _on_mid_transition_afternoon() -> void:
	current_phase = DayPhase.AFTERNOON_CLIENT
	TimeManager.current_minute = 720
	# poner al npc cliente en su posición
	phase_changed.emit()
