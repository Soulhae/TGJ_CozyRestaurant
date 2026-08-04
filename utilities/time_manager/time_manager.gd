extends Node

signal time_passed
signal phase_changed(phase: Phase)

enum Phase {
	MORNING,
	AFTERNOON,
	NIGHT,
}

@export var time_scale: float = 200.0

var time_elapsed: float = 480.0 # 08:00
var current_minute: int = 480
var current_phase: Phase = Phase.MORNING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.connect("time_passed", self.print_time)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time_elapsed >= 1320: # 22:00
		time_elapsed = 480
		
	time_elapsed += delta * time_scale
	if current_minute != int(time_elapsed):
		current_minute = int(time_elapsed)
		time_passed.emit()
		phase_change()


#func print_time() -> void:
	#var hours := int(time_elapsed) / 60
	#var minutes := int(time_elapsed) % 60
	#
	#print("%02d:%02d" % [hours, minutes])


func phase_change() -> void:
	var new_phase: Phase
	if current_minute < 720: # 12:00
		new_phase = Phase.MORNING
	elif current_minute < 1200: # 20:00
		new_phase = Phase.AFTERNOON
	elif current_minute >= 1200: # hasta 21:59
		new_phase = Phase.NIGHT
	
	if new_phase != current_phase:
		current_phase = new_phase
		phase_changed.emit(current_phase)
		#print(current_phase)


func set_normal_speed() -> void:
	time_scale = 200.0


func set_slowed_speed() -> void:
	time_scale = 2.0
