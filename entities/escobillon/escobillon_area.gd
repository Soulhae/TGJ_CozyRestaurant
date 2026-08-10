extends Area3D

var day_manager: Node = null

@onready var arrow_indicator: Sprite3D = %ArrowIndicator

func _ready() -> void:
	day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")


func _process(_delta: float) -> void:
	if day_manager and arrow_indicator:
		var show_arrow: bool = (day_manager.dishes_washed == true) and (day_manager.floor_swept == false)
		if arrow_indicator.visible != show_arrow:
			arrow_indicator.visible = show_arrow


func on_interact() -> void:
	if day_manager:
		if day_manager.dishes_washed == true and day_manager.floor_swept == false:
			day_manager.floor_swept = true
			#print("floor swept " , day_manager.floor_swept)
			AudioManager.play_sfx(AudioManager.mop_sfx)
			AudioManager.play_sfx(AudioManager.sponge_sfx)
			day_manager.check_morning_tasks()
