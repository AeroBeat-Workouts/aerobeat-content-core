class_name Workout
extends RefCounted

var id: String
var title: String
var mode: String
var steps: Array[Dictionary]

func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	title = data.get("title", "")
	mode = data.get("mode", "")
	steps = Array(data.get("steps", []), TYPE_DICTIONARY, "", null)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"mode": mode,
		"steps": steps,
	}
