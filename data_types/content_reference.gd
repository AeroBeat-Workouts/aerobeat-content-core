class_name ContentReference
extends RefCounted

const ContentId = preload("res://../data_types/content_id.gd")

var kind: String = ""
var id: String = ""
var package_id: String = ""

static func from_dict(data: Dictionary) -> ContentReference:
	var reference := ContentReference.new()
	reference.kind = String(data.get("kind", ""))
	reference.id = String(data.get("id", ""))
	reference.package_id = String(data.get("packageId", ""))
	return reference

func to_dict() -> Dictionary:
	return {
		"kind": kind,
		"id": id,
		"packageId": package_id,
	}

func is_valid() -> bool:
	return not kind.is_empty() and ContentId.is_valid_uid(id)
