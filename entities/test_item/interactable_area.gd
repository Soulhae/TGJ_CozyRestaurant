extends Area3D

const MINIGAME_QTE_SCENE: PackedScene = preload("res://utilities/2d_over_3d/minigame_qte/minigame_qte.tscn")

var is_busy: bool = false
var _is_player_in_range: bool = false
var player: CharacterBody3D = null

@onready var test_interact_label: Label3D = %TestInteractLabel
@onready var can_interact_icon: Sprite3D = %CanInteractIcon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(_is_player_in_range)
	pass


func on_interact() -> void:
	if not MINIGAME_QTE_SCENE.can_instantiate():
		return
	
	# acá quizá conectar la señal child_entered_tree de Node (ver como funciona) u otra custom
	# a las distintas cosas/escenas/nodos que necesiten 'pararse en el tiempo'
	player.set_process_unhandled_input(false)
	player.set_physics_process(false)
	var minigame_qte = MINIGAME_QTE_SCENE.instantiate()
	minigame_qte.qte_finished.connect(self._on_qte_finished)
	
	is_busy = true
	update_ui()
	test_interact_label.visible = true
	get_tree().current_scene.add_child(minigame_qte)


func update_ui(in_range: bool = _is_player_in_range) -> void:
	_is_player_in_range = in_range
	can_interact_icon.visible = _is_player_in_range and not is_busy


func _on_qte_finished(_success) -> void:
	await get_tree().create_timer(1.5).timeout
	test_interact_label.visible = false
	is_busy = false
	update_ui()
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)
