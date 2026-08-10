extends AnimatedSprite3D

@onready var main_sprite: AnimatedSprite3D = %AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta: float) -> void:
	animation = main_sprite.animation
	frame = main_sprite.frame
	flip_h = main_sprite.flip_h
