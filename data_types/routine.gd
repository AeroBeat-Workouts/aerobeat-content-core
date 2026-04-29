class_name Routine
extends RefCounted

const REQUIRED_FIELDS := ["schema", "routineId", "routineName", "songId", "feature", "authorId", "authorName", "charts"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
