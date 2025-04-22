extends "res://scripts/entity.gd"

@export var over : bool = false;

var text;
var index : int = 0;

func is_it_over(answer_label: Label):
	if text.size() == 0:
		return
	else:
		answer_text = text[index];
		answer_label.text = answer_text;
		question_text = "";
		index = index + 1;
		if index >= text.size():
			over = true;
