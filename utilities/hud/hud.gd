extends CanvasLayer

@onready var clock_label: Label = %ClockLabel
@onready var phase_label: Label = %PhaseLabel
@onready var test = TimeManager.Phase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	TimeManager.time_passed.connect(_on_time_passed)
	TimeManager.phase_changed.connect(_on_phase_changed)
	phase_label.text = test.keys()[0]
	_on_time_passed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_time_passed() -> void:
	var time: float = TimeManager.time_elapsed
	@warning_ignore("integer_division")
	var hours := int(time)/60
	var minutes := int(time)%60
	clock_label.text = "%02d:%02d" % [hours, minutes]


func _on_phase_changed(phase) -> void:
	phase_label.text = test.keys()[phase]
