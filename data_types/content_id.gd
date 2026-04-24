class_name ContentId
extends RefCounted

var kind: String
var value: String

func _init(p_kind: String = "", p_value: String = "") -> void:
	kind = p_kind
	value = p_value.strip_edges()

func is_valid() -> bool:
	return kind != "" and value != ""

func to_dict() -> Dictionary:
	return {
		"kind": kind,
		"value": value,
	}

static func from_dict(data: Dictionary) -> ContentId:
	return ContentId.new(data.get("kind", ""), data.get("value", ""))
