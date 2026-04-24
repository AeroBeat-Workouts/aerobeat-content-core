class_name ResolvedWorkoutStep
extends RefCounted

const REQUIRED_FIELDS := ["stepId", "chartId", "songId", "routineId", "mode", "difficulty"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
