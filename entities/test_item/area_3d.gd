extends Area3D

const MINIGAME_QTE_SCENE: PackedScene = preload("res://utilities/2d_over_3d/minigame_qte/minigame_qte.tscn")

var is_busy : bool = false
var _is_player_in_range : bool = false

@onready var test_interact_text: Label3D = %TestInteractText
@onready var can_interact_icon: Sprite3D = %CanInteractIcon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(_is_player_in_range)
	pass


func on_interact() -> void:
	if not MINIGAME_QTE_SCENE.can_instantiate():
		return
	
	#var minigame_qte = MINIGAME_QTE_SCENE.instantiate()
	
	is_busy = true
	update_ui()
	test_interact_text.visible = true
	#get_tree().current_scene.add_child(minigame_qte)
	await get_tree().create_timer(1.5).timeout
	#get_tree().current_scene.remove_child(minigame_qte)
	test_interact_text.visible = false
	is_busy = false
	update_ui()


func update_ui(in_range: bool = _is_player_in_range) -> void:
	_is_player_in_range = in_range
	can_interact_icon.visible = _is_player_in_range and not is_busy
