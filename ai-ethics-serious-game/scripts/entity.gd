extends Node2D
class_name EntityType

@export var entity_name : String = ""

@export_group("Question related properties")
@export_multiline var question_text : String = ""
@export_multiline var answer_text : String = ""
@export var is_answer_correct : bool = false
@export_range(0,100) var answer_ethical_value : int = 0

@export_group("Post-Question properties")
@export_multiline var explanation_text : String = ""
