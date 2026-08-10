extends Sprite3D

@onready var table_item_sprite: Sprite3D = %TableItemSprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	texture = table_item_sprite.texture
