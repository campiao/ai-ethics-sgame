extends Node

var entities_dict := {}

func _ready() -> void:
	entities_dict = load_json_file("res://resources/entities_data_v2.json")

func load_json_file(filePath: String):
	if FileAccess.file_exists(filePath):
		var data := FileAccess.open(filePath, FileAccess.READ)
		var parsed_data = JSON.parse_string(data.get_as_text())
		
		if parsed_data is Dictionary:
			return parsed_data
	else:
		push_warning("File does not exist!")
