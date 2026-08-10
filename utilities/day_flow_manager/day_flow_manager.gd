extends Node

signal phase_changed

const DIALOGUE_BOX_UI_SCENE: PackedScene = preload("res://utilities/2d_over_3d/dialogue_box_ui/dialogue_box_ui.tscn")


enum DayPhase {
	MORNING_ORGANIZING,
	AFTERNOON_CLIENT,
	AFTERNOON_COOKING,
	NIGHT_CLEANING,
	NIGHT_SLEEPING,
}

@export var client_npc: Node3D
@export var abuela_npc: Node3D
@export var frying_pan_node: StaticBody3D
@export var garbage_can: StaticBody3D
@export var next_day_scene: PackedScene
#@export var main_menu_scene: PackedScene
@export var has_morning_camera_tour: bool = false

@export_group("Diálogos del Día")
@export var morning_dialogue: DialogueData
@export var dialogue_client_arrived: DialogueData
@export var dialogue_client_order: DialogueData
@export var dialogue_cooking_tutorial: DialogueData
@export var dialogue_qte_tutorial: DialogueData
@export var dialogue_dish_ready: DialogueData
@export var dialogue_night_congrats: DialogueData
@export var dialogue_mateo_thoughts: DialogueData

@export_group("Receta del Día")
@export var recipe_of_the_day: RecipeData

var current_phase: DayPhase = DayPhase.MORNING_ORGANIZING
var tween: Tween
var cam_tween: Tween
var dishes_washed: bool = false
var floor_swept: bool = false
var player: CharacterBody3D = null
var qte_tutorial_played: bool = false

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var recipe_ui: CanvasLayer = %RecipeUI
@onready var fregadero_marker: Marker3D = %FregaderoMarker
@onready var verdulero_marker: Marker3D = %VerduleroMarker
@onready var platos_marker: Marker3D = %PlatosMarker
@onready var refri_marker: Marker3D = %RefriMarker
@onready var cocina_marker: Marker3D = %CocinaMarker
@onready var escobilla_marker: Marker3D = %EscobillaMarker
@onready var dialogue_box: CanvasLayer = %DialogueBoxUI
@onready var player_kitchen_marker: Marker3D = %PlayerKitchenMarker
@onready var abuela_kitchen_marker: Marker3D = %AbuelaKitchenMarker
@onready var abuela_wake_up_marker: Marker3D = %AbuelaWakeUpMarker
@onready var abuela_bar_counter_marker: Marker3D = %AbuelaBarCounterMarker


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_start_morning_sequence")


func _start_morning_sequence() -> void:
	player = get_tree().get_first_node_in_group("player")
	AudioManager.play_music(AudioManager.track_gameplay)
	if recipe_ui and recipe_of_the_day:
		recipe_ui.setup_recipe(recipe_of_the_day)
	
	if player:
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
	
	if dialogue_box:
		dialogue_box.dialogue_finished.connect(_on_morning_dialogue_finished)
		dialogue_box.line_shown.connect(_on_dialogue_line_shown)
		if morning_dialogue:
			if abuela_npc and abuela_wake_up_marker:
				abuela_npc.global_position = abuela_wake_up_marker.global_position
			await get_tree().create_timer(0.75).timeout
			dialogue_box.visible = true
			dialogue_box.call_deferred("start_dialogue", morning_dialogue)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(current_phase)
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_recipe"):
		if current_phase == DayPhase.AFTERNOON_COOKING:
			if recipe_ui:
				recipe_ui.visible = not recipe_ui.visible


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
	if abuela_npc and abuela_kitchen_marker:
		abuela_npc.global_position = abuela_kitchen_marker.global_position
	
	if garbage_can:
		garbage_can.visible = true
		
		var can_collision_shape = garbage_can.get_node_or_null("CollisionShape3D")
		var can_area = garbage_can.get_node_or_null("InteractableArea")
		
		if can_collision_shape:
			can_collision_shape.set_deferred("disabled", false)
		if can_area:
			can_area.monitoring = true
			can_area.monitorable = true
	
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
	if dishes_washed and floor_swept:
		advance_to_afternoon()


func _on_transition_finished() -> void:
	if current_phase == DayPhase.AFTERNOON_CLIENT:
		if dialogue_client_arrived:
			await _play_dialogue_and_wait(dialogue_client_arrived)
	elif current_phase == DayPhase.NIGHT_CLEANING:
		if dialogue_night_congrats:
			await _play_dialogue_and_wait(dialogue_night_congrats)
		
		await _play_sleep_sequence()
		return
	
	if player:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)


func _play_sleep_sequence() -> void:
	var canvas_layer := CanvasLayer.new()
	get_tree().current_scene.add_child(canvas_layer)
	var color_rect := ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0
	canvas_layer.add_child(color_rect)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(color_rect, "modulate:a", 1.0, 2.0)
	await fade_tween.finished
	
	if dialogue_mateo_thoughts:
		await _play_dialogue_and_wait(dialogue_mateo_thoughts)
	
	if next_day_scene:
		get_tree().change_scene_to_packed(next_day_scene)
	else:
		get_tree().change_scene_to_file("res://stages/main_menu/main_menu.tscn")


func _on_dialogue_line_shown(index: int) -> void:
	if not has_morning_camera_tour:
		return
	
	match index:
		0:
			if camera:
				camera.is_cinematic = true 
		14:
			_move_camera_to(fregadero_marker.global_position)
		15: 
			_move_camera_to(verdulero_marker.global_position)
		16: 
			_move_camera_to(cocina_marker.global_position)
		17: 
			_move_camera_to(refri_marker.global_position)
		18: 
			_move_camera_to(escobilla_marker.global_position)
		19:
			_move_camera_to(player.global_position + camera.player_offset)
		24:
			_move_camera_to(platos_marker.global_position)
		25: 
			_move_camera_to(player.global_position + camera.player_offset)


func _move_camera_to(target_pos: Vector3) -> void:
	if cam_tween and cam_tween.is_running():
		cam_tween.kill()
		
	cam_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	cam_tween.tween_property(camera, "global_position", target_pos, 1.5)


func _on_morning_dialogue_finished() -> void:
	if player:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)
	
	if camera:
		camera.is_cinematic = false


func play_afternoon_sequence() -> void:
	if player:
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
	
	if dialogue_client_order:
		await _play_dialogue_and_wait(dialogue_client_order)
		
	
	if dialogue_cooking_tutorial:
		var canvas_layer := CanvasLayer.new()
		get_tree().current_scene.add_child(canvas_layer)
		var color_rect := ColorRect.new()
		color_rect.color = Color.BLACK
		color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		color_rect.modulate.a = 0
		canvas_layer.add_child(color_rect)
		
		var fade_in = create_tween()
		fade_in.tween_property(color_rect, "modulate:a", 1.0, 0.5)
		await fade_in.finished
		
		if player and player_kitchen_marker:
			player.global_position = player_kitchen_marker.global_position
		if abuela_npc and abuela_kitchen_marker:
			abuela_npc.global_position = abuela_kitchen_marker.global_position
		
		var fade_out = create_tween()
		fade_out.tween_property(color_rect, "modulate:a", 0.0, 0.5)
		await fade_out.finished
		canvas_layer.queue_free()
		
		await _play_dialogue_and_wait(dialogue_cooking_tutorial)
	
	current_phase = DayPhase.AFTERNOON_COOKING
	
	if player:
		player.set_physics_process(true)
		player.set_process_unhandled_input(true)


func play_qte_tutorial() -> void:
	if dialogue_qte_tutorial and not qte_tutorial_played:
		qte_tutorial_played = true
		await _play_dialogue_and_wait(dialogue_qte_tutorial)


func _on_dish_cooked(_dish: ItemData) -> void:
	if current_phase == DayPhase.AFTERNOON_COOKING:
		if player:
			player.set_physics_process(false)
			player.set_process_unhandled_input(false)
			
		if dialogue_dish_ready:
			await _play_dialogue_and_wait(dialogue_dish_ready)
			
		if player:
			player.set_physics_process(true)
			player.set_process_unhandled_input(true)


func _play_dialogue_and_wait(data: DialogueData) -> void:
	var new_dialogue = DIALOGUE_BOX_UI_SCENE.instantiate()
	get_tree().current_scene.add_child(new_dialogue)
	new_dialogue.start_dialogue(data)
	await new_dialogue.dialogue_finished


func advance_to_night() -> void:
	current_phase = DayPhase.NIGHT_CLEANING
	
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
	tween.tween_callback(_on_mid_transition_night)
	tween.tween_interval(1)
	tween.tween_property(color_rect, "modulate:a", 0, 0.5)
	tween.tween_callback(canvas_layer.queue_free)
	tween.tween_callback(_on_transition_finished)


func _on_mid_transition_night() -> void:
	TimeManager.current_minute = 1260
	if client_npc:
		client_npc.visible = false
		var npc_area = client_npc.get_node_or_null("InteractableArea")
		if npc_area:
			npc_area.monitoring = false
			npc_area.monitorable = false
			
	if abuela_npc and abuela_bar_counter_marker:
		abuela_npc.global_position = abuela_bar_counter_marker.global_position
			
	phase_changed.emit()
