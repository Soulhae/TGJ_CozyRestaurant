extends TextureRect

const MAIN_MENU_SCENE = preload("res://stages/main_menu/main_menu.tscn")

@onready var back_button: Button = $BackButton

func _ready() -> void:
	if get_tree().current_scene == self:
		back_button.visible = false
	else:
		pass

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().current_scene == self:
		if event.is_action_pressed("QTE") or event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
			get_tree().quit()
