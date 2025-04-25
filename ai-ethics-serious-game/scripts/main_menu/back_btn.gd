extends Node

func on_button_pressed() -> void:
	var main_menu_scene := load("res://scenes/main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu_scene)
