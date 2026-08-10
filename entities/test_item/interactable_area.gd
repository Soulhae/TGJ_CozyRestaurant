extends Area3D

const MINIGAME_QTE_SCENE: PackedScene = preload("res://utilities/2d_over_3d/minigame_qte/minigame_qte.tscn")

@export var item_on_table: ItemData = null

#var is_busy: bool = false
#var _is_player_in_range: bool = false
var player: CharacterBody3D = null

@onready var test_interact_label: Label3D = %TestInteractLabel
@onready var arrow_indicator: Sprite3D = %ArrowIndicator
@onready var table_item_sprite: Sprite3D = %TableItemSprite
@onready var table_item_name: Label3D = %TableItemName


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	update_table_item_visual()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(_is_player_in_range)
	pass


func play_minigame_qte() -> void:
	#if not MINIGAME_QTE_SCENE.can_instantiate():
		#return
		
	player.set_process_unhandled_input(false)
	player.set_physics_process(false)
	
	var minigame_qte = MINIGAME_QTE_SCENE.instantiate()
	minigame_qte.qte_finished.connect(self._on_qte_finished)
	
	#is_busy = true
	#update_ui()
	#test_interact_label.visible = true
	get_tree().current_scene.add_child(minigame_qte)

# acá conectar las distintas cosas/escenas/nodos que necesiten 'pararse en el tiempo'
func on_interact() -> void:
	if player.held_item != null and item_on_table == null:
		item_on_table = player.held_item
		player.held_item = null
		player.update_held_item_visual()
		update_table_item_visual()
	elif player.held_item == null and item_on_table != null and item_on_table.processed_result != null:
		item_on_table = item_on_table.processed_result
		update_table_item_visual()
	elif player.held_item == null and item_on_table != null and item_on_table.processed_result == null:
		player.held_item = item_on_table
		item_on_table = null
		player.update_held_item_visual()
		update_table_item_visual()

#func update_ui(_in_range: bool = _is_player_in_range) -> void:
	##_is_player_in_range = in_range
	##can_interact_icon.visible = _is_player_in_range and not is_busy
	#pass


func _on_qte_finished(success) -> void:
	await get_tree().create_timer(1.5).timeout
	if success:
		item_on_table = item_on_table.processed_result
		update_table_item_visual()
	test_interact_label.visible = false
	#is_busy = false
	#update_ui()
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)


func update_table_item_visual() -> void:
	if item_on_table and item_on_table.item_icon:
		table_item_sprite.texture = item_on_table.item_icon
		table_item_sprite.modulate = item_on_table.item_color
		table_item_sprite.visible = true
		table_item_name.text = item_on_table.item_name
		table_item_name.modulate = item_on_table.item_color
		table_item_name.visible = true
	else:
		table_item_sprite.visible = false
		table_item_name.visible = false


func show_tutorial_arrow() -> void:
	if arrow_indicator:
		arrow_indicator.visible = true


func hide_tutorial_arrow() -> void:
	if arrow_indicator and arrow_indicator.visible:
		arrow_indicator.visible = false
