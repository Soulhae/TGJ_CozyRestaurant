extends Area3D

const DIRTY_DISHES: ItemData = preload("res://entities/various_items/dirty_dishes.tres")

var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact() -> void:
	if player.held_item == null:
		player.held_item = DIRTY_DISHES
		player.update_held_item_visual()
		
		get_parent().queue_free()
