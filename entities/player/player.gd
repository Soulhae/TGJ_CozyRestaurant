extends CharacterBody3D

@export var speed: float = 3.0

var target_velocity := Vector3.ZERO
var interactable_list : Array = []

@onready var visual_pivot: Node3D = $Pivot
@onready var interactable_area: Area3D = $Pivot/Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		interact()


func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		visual_pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	velocity = target_velocity
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	#print("entró un area3d")
	if area.has_method("update_ui"):
		area.update_ui(true)
		
	if not interactable_list.has(area):
		interactable_list.append(area)
	#print(interactable_list)


func _on_area_3d_area_exited(area: Area3D) -> void:
	#print("salió un area3d")
	if area.has_method("update_ui"):
		area.update_ui(false)
	
	if interactable_list.has(area):
		interactable_list.erase(area)
	#print(interactable_list)


func interact() -> void:
	var item : Area3D = get_distance_to_interactable()
	if not item:
		return
	
	if item.has_method("on_interact"):
		item.on_interact()


func get_distance_to_interactable() -> Area3D:
	var closest_item : Area3D = null
	var closest_item_distance: float = INF
	
	for item : Area3D in interactable_list:
		if not is_instance_valid(item):
			continue
			
		var distance : float = global_position.distance_to(item.global_position)
		if distance < closest_item_distance:
			closest_item_distance = distance
			closest_item = item
	
	interactable_list = interactable_list.filter(is_instance_valid)
	return closest_item
