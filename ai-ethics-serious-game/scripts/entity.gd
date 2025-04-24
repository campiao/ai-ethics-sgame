extends Node2D
class_name EntityType

@export var entity_name : String = ""

@export_group("Question related properties")
@export_multiline var question_text : String = ""
@export_multiline var answer_text : String = ""
@export var is_answer_correct : bool = false
@export_range(0,100) var confidence_target : int = 0

@export_group("Post-Question properties")
@export_multiline var feedback_perceptive : String = ""
@export_multiline var feedback_missed : String = ""
