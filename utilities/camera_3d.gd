extends Camera3D

@export var smooth_weight : float = 4.0
@export var player_offset := Vector3(0.0, 6.0, 2.0)

var target_position : Vector3

@onready var player: CharacterBody3D = %Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = player.global_position + player_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	target_position = player.global_position + player_offset
	global_position = global_position.lerp(target_position, smooth_weight * delta) 
	
