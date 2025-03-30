extends Node2D

# Answer and question labels
@onready var answer_label: Label = $UI/AnswerLabel
@onready var question_label: Label = $UI/QuestionLabel

# Background
@onready var background_image: TextureRect = $UI/BackgroundImage
@onready var two_btn_bg_image := preload("res://assets/sprites/backgrounds/game.png")
@onready var one_btn_bg_image := preload("res://assets/sprites/backgrounds/game_one_btn.png")

# Entity nodes
@onready var entity_sprite: AnimatedSprite2D = $UI/EntitySprite
@onready var title_entity_label: Label = $UI/TitleEntityLabel

# Progress label
@onready var progress_label: Label = $UI/ProgressLabel

# Entities
@onready var entities: Node2D = $Entities
@onready var entities_remaining := entities.get_children()

# Boss entity
@onready var boss_entity: EntityType = $BossEntity

# Buttons
@onready var accept_button: TextureButton = $UI/AcceptButton
@onready var decline_button: TextureButton = $UI/DeclineButton
@onready var ok_boss_button: TextureButton = $UI/OkBossButton

# Entities
var current_entity_id := -1
var entities_count := -1

# Flow control
var is_entity_visible := false
var is_tutorial_done := false
var is_on_after_selection := true

# Text animation speed
var text_update_speed := 2.0

# Boss flavor text
var correct_choice_flavor := [
	"You got it right, good job!",
	"Nice, that was a good one!",
	"Correct! I am proud of you.",
]
var wrong_choice_flavor := [
	"That's not correct, check above to see why!",
	"Wrong! It's okay, you will get it the next time!",
	"Incorrect option! Let me tell you why...",
]

func _ready() -> void:
	current_entity_id = 0
	entities_count = len(entities_remaining)
	
	progress_label.text = "Progress: " + str(current_entity_id) + "/" + \
						str(entities_count)
						
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	set_entities_data()
	show_tutorial()
	
func _process(_delta: float) -> void:
	if not is_entity_visible:
		setup_entity(entities_remaining[current_entity_id])
	else:
		if question_label.visible_ratio < 1.0:
			question_label.visible_ratio += \
			1.0/question_label.text.length()/text_update_speed
		elif answer_label.visible_ratio < 1.0:
			answer_label.visible_ratio += \
			1.0/answer_label.text.length()/text_update_speed
	
func set_entities_data() -> void:
	var data = StaticData.entities_dict
	var num_ent = len(data.keys())
	
	# ALERT: Something is causing the editor to lag and consume memory on
	# "run current scene", not sure if it is this function
	# Only happens on this scene ("level_one.tscn")
	
	for i in range(0, num_ent):
		entities_remaining[i].question_text = data[str(i)].get("question_text")
		entities_remaining[i].answer_text = data[str(i)].get("answer_text")
		entities_remaining[i].is_answer_correct = data[str(i)].get("is_answer_correct")
		
		entities_remaining[i].explanation_text = data[str(i)].get("explanation_text")
		
func  setup_entity(entity_data: EntityType) -> void:
	# Display entity data
	entity_sprite.sprite_frames = entity_data.get_child(0).sprite_frames
	entity_sprite.play("default")
	answer_label.text = entity_data.answer_text
	question_label.text = entity_data.question_text
	title_entity_label.text = entity_data.entity_name
	
	# Mark entity visible to prevent changing displayed data
	is_entity_visible = true

func _on_accept_button_pressed() -> void:
	if current_entity_id > entities_count-1:
		return
	
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	
	if not is_on_after_selection:
		advance_level()
	else:
		var is_choice_correct = true \
		if entities_remaining[current_entity_id].is_answer_correct \
		else false
		advance_to_boss_screen()
		setup_boss_text(entities_remaining[current_entity_id], is_choice_correct)
	
	
func _on_decline_button_pressed() -> void:
	if current_entity_id > entities_count - 1:
		return
	
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	if not is_on_after_selection:
		advance_level()
	else:
		var is_choice_correct = false \
		if entities_remaining[current_entity_id].is_answer_correct \
		else true
		advance_to_boss_screen()
		setup_boss_text(entities_remaining[current_entity_id], is_choice_correct)
	
func _on_ok_boss_button_pressed() -> void:
	if current_entity_id > entities_count - 1:
		# TODO: Show end game screen
		return
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	if not is_tutorial_done:
		current_entity_id -= 1
		is_tutorial_done = true
	advance_level()

func advance_to_boss_screen() -> void:
	#background_image.texture.reset_state()
	background_image.texture = one_btn_bg_image
	accept_button.hide()
	decline_button.hide()
	ok_boss_button.show()
	

func advance_to_normal_screen() -> void:
	ok_boss_button.hide()
	accept_button.show()
	decline_button.show()
	background_image.texture = two_btn_bg_image

func setup_boss_text(entity_data: EntityType,
	is_choice_correct: bool) -> void:
	boss_entity.answer_text = entity_data.explanation_text
	
	# TODO: Maybe make it so the same flavor text can't appear twice in a row
	boss_entity.question_text = correct_choice_flavor.pick_random() \
		if is_choice_correct \
		else wrong_choice_flavor.pick_random()
	setup_entity(boss_entity)
	is_on_after_selection = false

func advance_level() -> void:
	is_on_after_selection = true
	advance_to_normal_screen()
	
	current_entity_id += 1
	progress_label.text = "Progress: " + str(current_entity_id) + "/" + \
						str(entities_count)
	# TODO: End-game/level screen, triggered here
	if current_entity_id > entities_count-1:
		print("Level has ended, swap to main menu...")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	is_entity_visible = false

func show_tutorial() -> void:
	advance_to_boss_screen()
	setup_entity(boss_entity)
