extends Node3D

const NEXT_LEVEL_SCENE: PackedScene = preload("res://stages/arrival_scene/arrival_scene.tscn")

@export var room_dialogue: DialogueData

@onready var dialogue_box: CanvasLayer = $DialogueBoxUI
@onready var player: CharacterBody3D = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.music_player.stop()
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
	if room_dialogue:
		dialogue_box.start_dialogue(room_dialogue)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_dialogue_finished() -> void:
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 10 
	add_child(canvas_layer)
	
	var color_rect := ColorRect.new()
	color_rect.color = Color.BLACK
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0
	canvas_layer.add_child(color_rect)
	
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 1.5)
	
	tween.tween_callback(_change_to_next_level)


func _change_to_next_level() -> void:
	get_tree().change_scene_to_packed(NEXT_LEVEL_SCENE)
