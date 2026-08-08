extends Area3D

const GROCERIES_BOX: ItemData = preload("res://entities/food_items/groceries_box.tres")

var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact() -> void:
	if player.held_item == null:
		player.held_item = GROCERIES_BOX
		player.update_held_item_visual()
		
		get_parent().visible = false
		monitoring = false
