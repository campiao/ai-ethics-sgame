extends Node

@onready var levels_menu = $LevelsMenu
@onready var main_menu = $MainMenu

func _ready() -> void:
	levels_menu.visible = false;
	
func _process(delta: float) -> void:
	if Global.level_one_complete:
		$LevelsMenu/Level2Btn.disabled = false;
	else:
		$LevelsMenu/Level2Btn.disabled = true;
		

func _on_levels_button_pressed() -> void:
	levels_menu.visible = true;
	main_menu.visible = false;


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_button_pressed() -> void:
	levels_menu.visible = false;
	main_menu.visible = true;
	

func _on_level_1_btn_pressed() -> void:
	var level_one_scene := load("res://scenes/level_one.tscn")
	get_tree().change_scene_to_packed(level_one_scene)


func _on_level_2_btn_pressed() -> void:
	var level_two_scene := load("res://scenes/level_two.tscn")
	get_tree().change_scene_to_packed(level_two_scene)
