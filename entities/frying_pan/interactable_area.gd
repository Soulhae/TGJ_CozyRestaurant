extends Area3D

const MINIGAME_QTE_SCENE: PackedScene = preload("res://utilities/2d_over_3d/minigame_qte/minigame_qte.tscn")

@export var available_recipes: Array[RecipeData]

var added_items: Array[ItemData] = []
var ready_dish: ItemData = null
var is_cooking: bool = false
var current_recipe: RecipeData = null
var player: CharacterBody3D = null
var pulse_tween: Tween
var og_color: Color
var mat: StandardMaterial3D = null
@onready var station_sprite: Sprite3D = %StationSprite
@onready var station_item_name: Label3D = %StationItemName
@onready var cooking_timer: Timer = %CookingTimer
@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if mesh_instance_3d.material_override:
		mat = mesh_instance_3d.material_override as StandardMaterial3D
	elif mesh_instance_3d.mesh and mesh_instance_3d.mesh.get_material():
		mat = mesh_instance_3d.mesh.get_material() as StandardMaterial3D
		
	if mat:
		og_color = mat.albedo_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func on_interact() -> void:
	if is_cooking:
		# puede ser diálogo interno del personaje diciendo como 'no debería... me puedo quemar'
		return
	
	if ready_dish:
		if not player.held_item:
			player.held_item = ready_dish
			ready_dish = null
			player.update_held_item_visual()
			update_ready_dish_visual()
	
	if player.held_item:
		var added_items_copy = added_items.duplicate()
		added_items_copy.append(player.held_item)
		for recipe in available_recipes:
			if (
					is_recipe_compatible(recipe, added_items_copy)
					and recipe.required_items.has(player.held_item)
					and added_items.count(player.held_item) < recipe.required_items.count(player.held_item)
				):
				added_items.append(player.held_item)
				player.held_item = null
				player.update_held_item_visual()
				if added_items.size() == recipe.required_items.size():
					current_recipe = recipe
					start_cooking()
				break


func update_ready_dish_visual() -> void:
	if ready_dish:
		station_sprite.texture = ready_dish.item_icon
		station_sprite.modulate = ready_dish.item_color
		station_sprite.visible = true
		station_item_name.text = ready_dish.item_name
		station_item_name.visible = true
	else:
		station_sprite.visible = false
		station_item_name.visible = false

func start_cooking() -> void:
	is_cooking = true
	var day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")
	
	player.set_physics_process(false)
	player.set_process_unhandled_input(false)
	
	if day_manager and day_manager.has_method("play_qte_tutorial"):
		await day_manager.play_qte_tutorial()
		
	var minigame_qte = MINIGAME_QTE_SCENE.instantiate()
	get_tree().current_scene.add_child(minigame_qte)
	
	var _success = await minigame_qte.qte_finished 
	
	await get_tree().create_timer(1.0).timeout 
	
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
	
	TimeManager.set_slowed_speed()
	
	if mat:
		pulse_tween = create_tween().set_loops()
		pulse_tween.tween_property(mat, "albedo_color", Color.RED, 0.5)
		pulse_tween.tween_property(mat, "albedo_color", og_color, 0.5)
		
	cooking_timer.start(current_recipe.cooking_time)


func _on_cooking_timer_timeout() -> void:
	is_cooking = false
	
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
		
	var reset_tween = create_tween()
	reset_tween.tween_property(mat, "albedo_color", og_color, 0.2)
	
	ready_dish = current_recipe.final_result
	added_items.clear()
	current_recipe = null
	TimeManager.set_normal_speed()
	update_ready_dish_visual()


func is_recipe_compatible(recipe: RecipeData, test_items: Array[ItemData]) -> bool:
	for item in test_items:
		if test_items.count(item) > recipe.required_items.count(item):
			return false
	return true
