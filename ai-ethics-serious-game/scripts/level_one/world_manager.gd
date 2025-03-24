extends Node2D

# Answer and question labels
@onready var answer_label: Label = $UI/AnswerLabel
@onready var question_label: Label = $UI/QuestionLabel

# Entity nodes
@onready var entity_sprite: Sprite2D = $UI/EntitySprite
@onready var title_entity_label: Label = $UI/TitleEntityLabel

# Progress label
@onready var progress_label: Label = $UI/ProgressLabel

# Entities
@onready var entities: Node2D = $Entities
@onready var entities_remaining := entities.get_children()

var current_entity_id := -1
var entities_count := -1

var is_entity_visible := false

func _ready() -> void:
	#var first_entity := entities_remaining[0]
	#setup_entity(first_entity)
	current_entity_id = 0
	entities_count = len(entities_remaining)
	
	progress_label.text = "Progress: " + str(current_entity_id) + "/" + \
						str(entities_count)
	
func _process(_delta: float) -> void:
	if not is_entity_visible:
		setup_entity(entities_remaining[current_entity_id])
	
func  setup_entity(entity_data: EntityType) -> void:
	# Display entity data
	entity_sprite.texture = load(entity_data.sprite_path)
	answer_label.text = entity_data.answer_text
	question_label.text = entity_data.question_text
	title_entity_label.text = entity_data.entity_name
	
	# Mark entity visible to prevent changing displayed data
	is_entity_visible = true

func _on_accept_button_pressed() -> void:
	# TODO: Logic for pressing accept button
	advance_level()
	
func _on_decline_button_pressed() -> void:
	# TODO: Logic for pressing decline button
	advance_level()
	
func advance_level() -> void:
	current_entity_id += 1
	progress_label.text = "Progress: " + str(current_entity_id) + "/" + \
						str(entities_count)
	if current_entity_id > entities_count-1:
		print("Level has ended, swap to main menu...")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	is_entity_visible = false
