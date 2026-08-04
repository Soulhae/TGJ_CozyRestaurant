extends CanvasLayer

signal qte_finished(success : bool)

@export var needle_speed : float = 1250.0

var needle_direction: int = 1
var needle_final_position: float

@onready var qte_bar: ColorRect = %QTEBar
@onready var needle: ColorRect = %Needle
@onready var success_zone: ColorRect = %SuccessZone
@onready var outcome_label: Label = %OutcomeLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TimeManager.set_slowed_speed()
	success_zone.position.x = randf_range(0, qte_bar.size.x - success_zone.size.x)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("QTE"):
		set_process(false)
		needle_final_position = needle.position.x
		if (
				needle_final_position >= success_zone.position.x - needle.size.x 
				and needle_final_position <= success_zone.position.x + success_zone.size.x
		) :
			outcome_label.text = 'Success!! :D'
			outcome_label.visible = true
			qte_finished.emit(true)
		else:
			outcome_label.text = 'Failure :('
			outcome_label.visible = true
			qte_finished.emit(false)
		await get_tree().create_timer(1.5).timeout
		TimeManager.set_normal_speed()
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if needle.position.x <= 0:
		needle_direction = 1
	elif needle.position.x >= qte_bar.size.x - needle.size.x:
		needle_direction = -1
	
	needle.position.x += needle_direction * needle_speed * delta
	needle.position.x = clamp(needle.position.x, 0, qte_bar.size.x - needle.size.x)
