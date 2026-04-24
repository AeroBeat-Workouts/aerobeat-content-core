class_name Workout
extends RefCounted

const REQUIRED_FIELDS := ["schema", "workoutId", "workoutName", "description", "coachId", "coachName", "steps"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
