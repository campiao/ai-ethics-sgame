extends Node2D

# Answer and question labels
@onready var answer_label: Label = $UI/AnswerLabel
@onready var question_label: Label = $UI/QuestionLabel

# Background
@onready var background_image: TextureRect = $UI/BackgroundImage

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
@onready var ok_boss_button: TextureButton = $UI/OkBossButton

# End-game/level screen
@onready var post_level_screen: Control = $PostLevelScreen

# Slider
@onready var confidence_slider: HSlider = $UI/HSlider

# Entities
var current_entity_id := -1
var entities_count := -1

# Flow control
var is_entity_visible := false
var is_tutorial_done := false
var is_on_after_selection := true
var is_level_over := false

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

var first_level_text := [
	"Today, you’ll review decisions made by AI in critical areas: healthcare, education, security.",
	"Your task is to evaluate how much trust each decision deserves. Use the slider to indicate your judgment.",
	"Remember: your choices have real consequences for the system, and for people’s lives.",
	"Don’t trust blindly. Don’t reject without thought.",
	"The first case is ready."
]

# Correct guesses
var num_correct_guesses := -1
var is_audio_playing := false
# Score
var score := -1

func _ready() -> void:
	current_entity_id = -1
	entities_count = len(entities_remaining)
	num_correct_guesses = 0
	score = 0
	
	progress_label.text = "Progress: " + str(current_entity_id) + "/" + \
						str(entities_count)
						
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	boss_entity.text = first_level_text
	set_entities_data()
	show_tutorial()
	
func _process(_delta: float) -> void:
	if is_level_over:
		return
	if not is_entity_visible:
		setup_entity(entities_remaining[current_entity_id])
	else:
		if question_label.visible_ratio < 1.0:
			if not is_audio_playing:
				$SFX/RobotTalk.play()
				is_audio_playing = true
				
			question_label.visible_ratio += \
			1.0/question_label.text.length()/text_update_speed
			
		elif answer_label.visible_ratio < 1.0:

			answer_label.visible_ratio += \
			1.0/answer_label.text.length()/text_update_speed
		else:
			if is_audio_playing:
				$SFX/RobotTalk.stop()
				is_audio_playing = false
	
func set_entities_data() -> void:
	var data = StaticData.entities_dict
	var num_ent = len(data.keys())
	
	# ALERT: Something is causing the editor to lag and consume memory on
	# "run current scene", not sure if it is this function
	# Only happens on this scene ("level_one.tscn")
	
	for i in range(0, num_ent):
		entities_remaining[i].question_text = data[str(i)].get("question_text")
		entities_remaining[i].answer_text = data[str(i)].get("answer_text")
		entities_remaining[i].confidence_target = data[str(i)].get("confidence_target")
		entities_remaining[i].feedback_perceptive = data[str(i)].get("feedback_perceptive")
		entities_remaining[i].feedback_missed = data[str(i)].get("feedback_missed")
		
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
	base_button_logic()
	$SFX/ClickSound.play()
	var confidence_value := confidence_slider.value
	var is_choice_correct = check_is_answer_correct(confidence_value)
	advance_to_boss_screen()
	setup_boss_text(entities_remaining[current_entity_id], is_choice_correct)
	
func _on_ok_boss_button_pressed() -> void:
	base_button_logic()
	$SFX/ClickSound.play()
	if not boss_entity.over:
		boss_entity.is_it_over(answer_label);
	else:
		$UI/TitleQuestionLabel.visible = true
		advance_level()

func base_button_logic() -> void:
	if current_entity_id > entities_count-1:
		return
	
	answer_label.visible_ratio = 0.0
	question_label.visible_ratio = 0.0
	
func check_is_answer_correct(confidence_value : int) -> bool:
	var is_answer_correct := false
	
	var target : int = entities_remaining[current_entity_id].confidence_target
	
	if abs(target - confidence_value) > 20:
		return is_answer_correct
	elif abs(target - confidence_value) > 10:
		score += 1
	else:
		score += 2
	
	return not is_answer_correct

func advance_to_boss_screen() -> void:
	accept_button.hide()
	ok_boss_button.show()
	
	
	

func advance_to_normal_screen() -> void:
	ok_boss_button.hide()
	accept_button.show()
	
	$UI/TitleAnswerLabel.text = "DETAILS"
	$UI/TitleQuestionLabel.text = "SUMMARY"

func setup_boss_text(entity_data: EntityType,
	is_choice_correct: bool) -> void:
	if is_choice_correct:
		boss_entity.answer_text = entity_data.feedback_perceptive
	else:
		boss_entity.answer_text = entity_data.feedback_missed
	
	$UI/TitleAnswerLabel.text = "EFFECT"
	$UI/TitleQuestionLabel.text = "ANSWER"
	
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
	
	# NOTE: End level sequence here
	if current_entity_id > entities_count-1:
		if is_audio_playing:
			$SFX/RobotTalk.stop()
			is_audio_playing = false
		post_level_screen.set_stats_results(score,
											entities_count)
		post_level_screen.show()
		is_level_over = true
		return
	
	is_entity_visible = false

func show_tutorial() -> void:
	$UI/TitleAnswerLabel.text = "MESSAGE"
	$UI/TitleQuestionLabel.visible = false
	advance_to_boss_screen()
	setup_entity(boss_entity)
