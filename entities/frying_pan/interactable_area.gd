extends Area3D

@export var available_recipes: Array[RecipeData]

var added_items: Array[ItemData] = []
var ready_dish: ItemData = null
var is_cooking: bool = false
var current_recipe: RecipeData = null
var player: CharacterBody3D = null

@onready var station_sprite: Sprite3D = %StationSprite
@onready var station_item_name: Label3D = %StationItemName
@onready var cooking_timer: Timer = %CookingTimer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


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
		#if current_recipe != null:
			#if added_items.size() == current_recipe.required_items.size():
				#start_cooking()
		
		for recipe in available_recipes:
			if recipe.required_items.has(player.held_item) and not added_items.has(player.held_item):
				added_items.append(player.held_item)
				player.held_item = null
				player.update_held_item_visual()
				current_recipe = recipe
				if added_items.size() == current_recipe.required_items.size():
					start_cooking()


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
	TimeManager.set_slowed_speed()
	cooking_timer.start(current_recipe.cooking_time)


func _on_cooking_timer_timeout() -> void:
	is_cooking = false
	ready_dish = current_recipe.final_result
	added_items.clear()
	current_recipe = null
	TimeManager.set_normal_speed()
	update_ready_dish_visual()
