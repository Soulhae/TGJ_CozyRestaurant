extends Area3D

func on_interact() -> void:
	var day_manager = get_tree().current_scene.get_node_or_null("DayFlowManager")
	
	if day_manager:
		if day_manager.dishes_washed == true and day_manager.floor_swept == false:
			day_manager.floor_swept = true
			#print("floor swept " , day_manager.floor_swept)
			AudioManager.play_sfx(AudioManager.sponge_sfx)
			day_manager.check_morning_tasks()
