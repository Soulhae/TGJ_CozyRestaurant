extends Area3D

const DIALOGUE_BOX_UI_SCENE: PackedScene = preload("res://utilities/2d_over_3d/dialogue_box_ui/dialogue_box_ui.tscn")
@export var waiting_dialogue: DialogueData
@export var correct_food_dialogue: DialogueData 
@export var wrong_food_dialogue: DialogueData
@export var target_dish: ItemData
@export var client_texture: Texture2D

var player: CharacterBody3D = null
var has_ordered: bool = false

@onready var client_sprite: Sprite3D = %ClientSprite

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if client_texture != null:
		client_sprite.texture = client_texture


func on_interact() -> void:
	var day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")

	if not has_ordered:
		has_ordered = true
		if day_manager and day_manager.has_method("play_afternoon_sequence"):
			day_manager.play_afternoon_sequence()
		return
	
	if player.held_item:
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		TimeManager.set_slowed_speed()
		
		var dialogue_box_ui: CanvasLayer = DIALOGUE_BOX_UI_SCENE.instantiate()
		dialogue_box_ui.dialogue_finished.connect(_on_food_delivered) 
		get_tree().current_scene.add_child(dialogue_box_ui)
		
		if player.held_item == target_dish:
			dialogue_box_ui.start_dialogue(correct_food_dialogue)
		else:
			dialogue_box_ui.start_dialogue(wrong_food_dialogue)
		
		player.held_item = null
		player.update_held_item_visual()
		
	else:
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		
		var dialogue_box_ui: CanvasLayer = DIALOGUE_BOX_UI_SCENE.instantiate()
		dialogue_box_ui.dialogue_finished.connect(_on_dialogue_finished)
		get_tree().current_scene.add_child(dialogue_box_ui)
		
		dialogue_box_ui.start_dialogue(waiting_dialogue)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)


func _on_food_delivered() -> void:
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	TimeManager.set_normal_speed()
	
	var day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")
	if day_manager and day_manager.has_method("advance_to_night"):
		day_manager.advance_to_night()
