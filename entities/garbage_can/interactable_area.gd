extends Area3D

var player: CharacterBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact():
	if player.held_item == null:
		return
	
	player.held_item = null
	player.update_held_item_visual()
	# sonido / partículas del basurero
