extends Control

@onready var text_to_render: Control = $TextToRender
@onready var text_components := text_to_render.get_children()

@onready var text_correct_guesses: Label = $TextToRender/NumCorrectGuesses
@onready var text_error_percentage: Label = $TextToRender/ErrorPercentage
@onready var text_end_level: Label = $TextToRender/EndLevelText

@export_multiline var good_ending_text := ""
@export_multiline var bad_ending_text := ""

var current_id := -1
var num_text_remaining := -1

var score_value := -1
var error_percentage := -1.0
var entities_count := -1

var text_update_speed := 3.0

func _ready() -> void:
	num_text_remaining = len(text_components)
	current_id = 0
	
	for elem: Label in text_components:
		elem.visible_ratio = 0.0
	

func _process(_delta: float) -> void:
	if current_id > num_text_remaining -1:
		return
	if visible:
		var has_finished_drawing := draw_text_component(current_id)
		if has_finished_drawing:
			current_id += 1
		
func draw_text_component(id: int) -> bool:
	if text_components[id].visible_ratio >= 1.0:
		return true
	else:
		text_components[id].visible_ratio += \
		1.0/text_components[id].text.length()/text_update_speed
	return false
	
func set_stats_results(score_result, num_entities : int) -> void:
	# TODO: add perfect and missed choice stats
	score_value = score_result
	entities_count = num_entities
	error_percentage = 1.0 - float(num_entities*2 - score_value)/(num_entities*2)
	set_text_to_display()
	
func set_text_to_display() -> void:
	text_correct_guesses.text = "Total score: "+str(score_value) + \
								"/"+str(entities_count * 2)
	text_error_percentage.text = "Percentage of total possible score: "+ \
								str(error_percentage*100) + "%"
	if error_percentage > 0.71:
		text_end_level.text = bad_ending_text
	else:
		text_end_level.text = good_ending_text


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("left_mouse_btn_clicked") and \
		current_id == num_text_remaining:
			# NOTE: check for success, change to corresponding scene!
			if error_percentage > 0.71:
				StaticData.entities_dict = StaticData.load_json_file("res://resources/entities_data_v2_2.json")
				get_tree().change_scene_to_file("res://scenes/level_one.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/level_two.tscn")
