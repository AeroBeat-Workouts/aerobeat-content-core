class_name Workout
extends RefCounted

const WorkoutStep = preload("res://../data_types/workout_step.gd")

const REQUIRED_FIELDS := ["schema", "workoutId", "workoutName", "description", "coachId", "coachName", "steps"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_steps_shape(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not data.has("steps"):
		return issues
	var steps_value: Variant = data.get("steps")
	if not (steps_value is Array):
		issues.append({
			"code": "workout_steps_invalid_type",
			"message": "Workout steps must be an array of workout-step records.",
		})
		return issues
	for index in range(steps_value.size()):
		var step_value: Variant = steps_value[index]
		if not (step_value is Dictionary):
			issues.append({
				"code": "workout_step_invalid_type",
				"message": "Workout step entries must be dictionaries.",
				"index": index,
			})
			continue
		var missing_fields := WorkoutStep.validate_shape(step_value)
		for field in missing_fields:
			issues.append({
				"code": "workout_step_missing_field",
				"message": "Workout step is missing required field '%s'." % field,
				"field": field,
				"index": index,
				"stepId": String(step_value.get("stepId", "")),
			})
	return issues
