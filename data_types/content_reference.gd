class_name ContentReference
extends RefCounted

var kind: String
var id: String
var package_id: String
var path: String

func _init(p_kind: String = "", p_id: String = "", p_package_id: String = "", p_path: String = "") -> void:
	kind = p_kind
	id = p_id
	package_id = p_package_id
	path = p_path

func key() -> String:
	return "%s:%s" % [kind, id]

func is_valid() -> bool:
	return kind != "" and id != ""

func to_dict() -> Dictionary:
	return {
		"kind": kind,
		"id": id,
		"package_id": package_id,
		"path": path,
	}
