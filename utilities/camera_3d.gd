extends Camera3D

@export var smooth_weight : float = 4.0
@export var player_offset := Vector3(0.0, 6.0, 2.0)
@export var min_limit := Vector2(-5.0, -5.0) 
@export var max_limit := Vector2(5.0, 6.4)

var target_position : Vector3
var is_cinematic: bool = false

@onready var player: CharacterBody3D = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = player.global_position + player_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if is_cinematic:
		return
	
	target_position = player.global_position + player_offset
	target_position.x = clamp(target_position.x, min_limit.x, max_limit.x)
	target_position.z = clamp(target_position.z, min_limit.y, max_limit.y)
	global_position = global_position.lerp(target_position, smooth_weight * delta) 
	
