extends CanvasLayer

var current_recipe: RecipeData = null

@onready var texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TextureRect
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var ingredients_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/IngredientsLabel

func _ready() -> void:
	visible = false


func setup_recipe(recipe: RecipeData) -> void:
	if recipe:
		current_recipe = recipe
		title_label.text = "Receta: " + recipe.final_result.item_name
		texture_rect.texture = recipe.final_result.item_icon
		texture_rect.modulate = recipe.final_result.item_color
		
		update_ingredient_status([]) 


func update_ingredient_status(added_items: Array[ItemData]) -> void:
	if not current_recipe:
		return
		
	var ingredients_text = "Ingredientes:\n"
	var added_items_copy = added_items.duplicate()
	
	for item in current_recipe.required_items:
		if item in added_items_copy:
			ingredients_text += "[color=green]- " + item.item_name + "[/color]\n"
			added_items_copy.erase(item) 
		else:
			ingredients_text += "- " + item.item_name + "\n"
			
	ingredients_label.text = ingredients_text
