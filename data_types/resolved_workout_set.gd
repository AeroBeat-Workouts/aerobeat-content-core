class_name ResolvedWorkoutSet
extends RefCounted

const REQUIRED_FIELDS := ["stepId", "setId", "chartId", "songId", "environmentId", "feature", "difficulty"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
