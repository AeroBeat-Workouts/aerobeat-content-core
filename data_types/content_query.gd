class_name ContentQuery
extends RefCounted

var kinds: PackedStringArray = []
var ids: PackedStringArray = []
var feature: String = ""
var difficulty: String = ""
var tags: PackedStringArray = []

func to_dict() -> Dictionary:
	return {
		"kinds": Array(kinds),
		"ids": Array(ids),
		"feature": feature,
		"difficulty": difficulty,
		"tags": Array(tags),
	}
