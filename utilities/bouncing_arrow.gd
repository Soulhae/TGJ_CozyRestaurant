extends Node3D

var original_y: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_y = position.y
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", original_y + 0.15, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", original_y, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
