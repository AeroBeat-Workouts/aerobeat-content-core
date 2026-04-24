class_name WorkoutStep
extends RefCounted

const REQUIRED_FIELDS := ["stepId", "chartId"]
const OPTIONAL_REFERENCE_FIELDS := ["songId", "routineId"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func optional_reference_fields() -> Array[String]:
	return OPTIONAL_REFERENCE_FIELDS.duplicate()
