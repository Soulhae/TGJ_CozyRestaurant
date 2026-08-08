extends Node

signal phase_changed

enum DayPhase {
	MORNING_ORGANIZING,
	AFTERNOON_CLIENT,
	AFTERNOON_COOKING,
	NIGHT_CLEANING,
	NIGHT_SLEEPING,
}

@export var client_npc: Node3D

var current_phase: DayPhase = DayPhase.MORNING_ORGANIZING
var tween: Tween
var pantry_stocked: bool = false
var fridge_stocked: bool = false
var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func advance_to_afternoon() -> void:
	current_phase = DayPhase.AFTERNOON_CLIENT
	
	if player:
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
	
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
	tween.tween_callback(_on_transition_finished)


func _on_mid_transition_afternoon() -> void:
	current_phase = DayPhase.AFTERNOON_CLIENT
	TimeManager.current_minute = 720
	if client_npc:
		client_npc.visible = true
		
		var npc_collision_shape = client_npc.get_node_or_null("MainCollisionShape")
		var npc_area = client_npc.get_node_or_null("InteractableArea")
		
		if npc_collision_shape:
			npc_collision_shape.set_deferred("disabled", false)
		if npc_area:
			npc_area.monitoring = true
			npc_area.monitorable = true
			
	phase_changed.emit()


func check_morning_tasks() -> void:
	if pantry_stocked and fridge_stocked:
		advance_to_afternoon()


func _on_transition_finished() -> void:
	if player:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)
