extends CanvasLayer

signal item_selected(item: ItemData)
signal select_canceled()

@onready var grid_container: GridContainer = %GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		select_canceled.emit()
		queue_free()


func setup_catalog(available_items: Array[ItemData]) -> void:
	for item in available_items:
		var item_button := Button.new()
		item_button.text = item.item_name
		item_button.icon = item.item_icon
		item_button.expand_icon = true
		item_button.custom_minimum_size = Vector2(273, 100)
		item_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_button.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		item_button.pressed.connect(_on_button_pressed.bind(item))
		grid_container.add_child(item_button)
	if grid_container.get_child_count() > 0:
		var first_button : Button = grid_container.get_child(0)
		first_button.grab_focus()


func _on_button_pressed(item: ItemData) -> void:
	item_selected.emit(item)
	queue_free()
