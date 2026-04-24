class_name ContentQuery
extends RefCounted

var kind: String
var mode: String
var tags: Array[String]
var difficulty: String

func _init(p_kind: String = "", p_mode: String = "", p_tags: Array[String] = [], p_difficulty: String = "") -> void:
	kind = p_kind
	mode = p_mode
	tags = p_tags.duplicate()
	difficulty = p_difficulty

func to_dict() -> Dictionary:
	return {
		"kind": kind,
		"mode": mode,
		"tags": tags,
		"difficulty": difficulty,
	}
