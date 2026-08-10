extends Area3D

const DIRTY_DISHES: ItemData = preload("res://entities/various_items/dirty_dishes.tres")

var player: CharacterBody3D = null

@onready var arrow_indicator: Node3D = %ArrowIndicator


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if player and player.held_item == DIRTY_DISHES:
		arrow_indicator.visible = true
	else:
		arrow_indicator.visible = false


func on_interact() -> void:
	if player and player.held_item == DIRTY_DISHES:
		player.held_item = null
		player.update_held_item_visual()
		
		var day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")
		if day_manager:
			day_manager.dishes_washed = true
			#print("dishes washed " , day_manager.dishes_washed)
			AudioManager.play_sfx(AudioManager.water_flow_sfx)
			day_manager.check_morning_tasks()
