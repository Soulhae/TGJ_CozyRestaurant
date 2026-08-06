extends Area3D

const DIALOGUE_BOX_UI_SCENE: PackedScene = preload("res://utilities/2d_over_3d/dialogue_box_ui/dialogue_box_ui.tscn")
const TEST_CAMILA = preload("uid://cqjp5oq2gbkjn")
const TEST_CAMILA_ALREADY_TALKED = preload("uid://cu76uhx7no1ix")


var player: CharacterBody3D = null
var expected_dish: ItemData = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact() -> void:
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	TimeManager.set_slowed_speed()
	
	var dialogue_box_ui: CanvasLayer = DIALOGUE_BOX_UI_SCENE.instantiate()
	dialogue_box_ui.dialogue_finished.connect(_on_dialogue_finished)
	dialogue_box_ui.option_selected.connect(_on_option_selected)
	get_tree().current_scene.add_child(dialogue_box_ui)
	
	if not player.held_item:
		if not expected_dish:
			dialogue_box_ui.start_dialogue(TEST_CAMILA)
		else:
			dialogue_box_ui.start_dialogue(TEST_CAMILA_ALREADY_TALKED)
	elif player.held_item:
		var response = DialogueData.new()
		response.character_name = "Camila"
		
		if player.held_item == expected_dish:
			response.lines.assign([
				"Que recuerdos con este " + expected_dish.item_name + "...",
				"Tiene muy buena pinta, muchas gracias."
			])
		else:
			response.lines.assign([
				"Mmmm, esto no parece " + expected_dish.item_name + "...",
				"Pero a veces las mejores cosas en la vida son imprevistas, muchas gracias."
			])
		
		player.held_item = null
		player.update_held_item_visual()
		expected_dish = null
		dialogue_box_ui.start_dialogue(response)


func _on_dialogue_finished() -> void:
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	TimeManager.set_normal_speed()


func _on_option_selected(choice: DialogueChoice) -> void:
	if choice.associated_dish != null:
		expected_dish = choice.associated_dish
