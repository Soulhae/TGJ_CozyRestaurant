extends Area3D

const ITEM_SELECTOR_SCENE: PackedScene = preload("res://utilities/2d_over_3d/item_selector_ui/item_selector_ui.tscn")

@export var available_items: Array[ItemData]

var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact():
	var day_manager := get_tree().current_scene.get_node("DayFlowManager")
	
	if player.held_item != null:
		AudioManager.play_sfx(AudioManager.error_sfx)
		return
	
	if day_manager.current_phase != day_manager.DayPhase.AFTERNOON_COOKING:
		return
	
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	
	var item_selector = ITEM_SELECTOR_SCENE.instantiate()
	item_selector.item_selected.connect(_on_item_selected)
	item_selector.select_canceled.connect(_on_select_canceled)
	get_tree().current_scene.add_child(item_selector)
	item_selector.setup_catalog(available_items)
	


func _on_item_selected(selected_item: ItemData) -> void:
	player.held_item = selected_item
	player.update_held_item_visual()
	
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)


func _on_select_canceled() -> void:
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
