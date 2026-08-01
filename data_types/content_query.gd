class_name ContentQuery
extends RefCounted

var kinds: PackedStringArray = []
var ids: PackedStringArray = []
var mode: String = ""
var difficulty: String = ""
var tags: PackedStringArray = []

func to_dict() -> Dictionary:
	return {
		"kinds": Array(kinds),
		"ids": Array(ids),
		"mode": mode,
		"difficulty": difficulty,
		"tags": Array(tags),
	}
