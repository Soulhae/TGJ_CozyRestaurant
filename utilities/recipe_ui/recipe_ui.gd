extends CanvasLayer

@onready var texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/TextureRect
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var ingredients_label: Label = $PanelContainer/MarginContainer/VBoxContainer/IngredientsLabel

func _ready() -> void:
	visible = false

func setup_recipe(recipe: RecipeData) -> void:
	if recipe:
		title_label.text = "Receta: " + recipe.final_result.item_name
		texture_rect.texture = recipe.final_result.item_icon
		texture_rect.modulate = recipe.final_result.item_color
		
		var ingredients_text = "Ingredientes:\n"
		for item in recipe.required_items:
			ingredients_text += "- " + item.item_name + "\n"
			
		ingredients_label.text = ingredients_text
