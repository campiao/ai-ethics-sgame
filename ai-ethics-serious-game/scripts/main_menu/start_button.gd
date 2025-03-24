extends Button


func on_button_pressed() -> void:
	var level_one_scene := load("res://scenes/level_one.tscn")
	get_tree().change_scene_to_packed(level_one_scene)
	pass # Replace with function body.
