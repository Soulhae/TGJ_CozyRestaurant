extends CanvasLayer

signal dialogue_finished
signal option_selected(choice: DialogueChoice)

@export var char_speed: float = 30.0

var current_index: int = 0
var tween: Tween
var local_data: DialogueData = null
var is_waiting_for_choice: bool = false

@onready var talking_character_name: Label = %TalkingCharacterName
@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var grid_container: GridContainer = %GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if local_data == null or is_waiting_for_choice:
		return
	
	if event.is_action_pressed("QTE"):
		advance_dialogue()


func start_dialogue(data: DialogueData = null) -> void:
	if data != null:
		local_data = data
		current_index = 0
	
	if local_data == null:
		return
	
	if current_index >= local_data.lines.size():
		if not local_data.choices.is_empty():
			show_choices(local_data.choices)
			return
		
		dialogue_finished.emit()
		queue_free()
		return
	
	if tween and tween.is_running():
		tween.kill()
	
	dialogue_label.text = local_data.lines[current_index]
	dialogue_label.visible_ratio = 0
	talking_character_name.text = local_data.character_name
	
	var total_chars: int = dialogue_label.get_parsed_text().length()
	var duration: float = total_chars / char_speed
	
	tween = create_tween()
	tween.tween_property(dialogue_label, "visible_ratio", 1.0, duration)


func advance_dialogue() -> void:
	if tween and tween.is_running():
		tween.kill()
		dialogue_label.visible_ratio = 1.0
	else:
		current_index += 1
		start_dialogue()


func show_choices(choices: Array[DialogueChoice]) -> void:
	is_waiting_for_choice = true
	
	for child in grid_container.get_children():
		child.queue_free()
	
	for choice in choices:
		var choice_button := Button.new()
		choice_button.text = choice.choice_text
		choice_button.pressed.connect(_on_button_pressed.bind(choice))
		grid_container.add_child(choice_button)
	if grid_container.get_child_count() > 0:
		var first_button : Button = grid_container.get_child(0)
		first_button.grab_focus()


func _on_button_pressed(choice: DialogueChoice) -> void:
	is_waiting_for_choice = false
	option_selected.emit(choice)
	
	for child in grid_container.get_children():
		child.queue_free()
	
	if choice.next_dialogue:
		start_dialogue(choice.next_dialogue)
	else:
		dialogue_finished.emit()
		queue_free()
