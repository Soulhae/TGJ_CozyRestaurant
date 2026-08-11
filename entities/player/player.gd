extends CharacterBody3D

signal item_deleted

@export var speed: float = 3.0

var target_velocity := Vector3.ZERO
var interactable_list: Array = []
var held_item: ItemData = null
var last_dir_name: String = "s"

@onready var visual_pivot: Node3D = %Pivot
@onready var interactable_area: Area3D = %InteractArea
@onready var held_item_sprite: Sprite3D = %HeldItemSprite
@onready var animated_sprite_3d: AnimatedSprite3D = %AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()
	if event.is_action_pressed("delete_item"):
		if held_item:
			held_item = null
			item_deleted.emit()
			AudioManager.play_sfx(AudioManager.delete_sfx)
		update_held_item_visual()


func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Vector3(input_dir.x, 0, input_dir.y)
	
	if direction != Vector3.ZERO:
		visual_pivot.basis = Basis.looking_at(direction)
	
	update_animation(input_dir)
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	velocity = target_velocity
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.has_method("update_ui"):
		area.update_ui(true)
		
	if not interactable_list.has(area):
		interactable_list.append(area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.has_method("update_ui"):
		area.update_ui(false)
	
	if interactable_list.has(area):
		interactable_list.erase(area)


func interact() -> void:
	var item: Area3D = get_distance_to_interactable()
	if not item:
		return
	
	if item.has_method("on_interact"):
		item.on_interact()


func get_distance_to_interactable() -> Area3D:
	var closest_item: Area3D = null
	var closest_item_distance: float = INF
	
	for item: Area3D in interactable_list:
		if not is_instance_valid(item):
			continue
			
		var distance: float = global_position.distance_to(item.global_position)
		if distance < closest_item_distance:
			closest_item_distance = distance
			closest_item = item
	
	interactable_list = interactable_list.filter(is_instance_valid)
	return closest_item


func update_held_item_visual() -> void:
	if held_item and held_item.item_icon:
		held_item_sprite.texture = held_item.item_icon
		held_item_sprite.modulate = held_item.item_color
		var s = held_item.custom_scale
		held_item_sprite.scale = Vector3(s, s, s)
		held_item_sprite.visible = true
	else:
		held_item_sprite.visible = false


func update_animation(input_dir: Vector2) -> void:
	if input_dir != Vector2.ZERO:
		var dir_name := ""
		
		if input_dir.x < -0.3:
			animated_sprite_3d.flip_h = false
			dir_name += "a"
		elif input_dir.x > 0.3:
			animated_sprite_3d.flip_h = true
			dir_name += "d"
			
		if input_dir.y < -0.3:
			dir_name = "w" + dir_name
		elif input_dir.y > 0.3:
			dir_name = "s" + dir_name
			
		var anim_to_play := _get_mirrored_anim_name(dir_name)
		
		if anim_to_play != "":
			last_dir_name = anim_to_play
			animated_sprite_3d.play("walk_" + last_dir_name)
	else:
		animated_sprite_3d.play("idle_" + last_dir_name)


func force_idle() -> void:
	velocity = Vector3.ZERO

	if animated_sprite_3d:
		animated_sprite_3d.play("idle_" + last_dir_name)


func _get_mirrored_anim_name(dir: String) -> String:
	match dir:
		"d": return "a"
		"sd": return "as"
		"wd": return "aw"
		_: return dir
