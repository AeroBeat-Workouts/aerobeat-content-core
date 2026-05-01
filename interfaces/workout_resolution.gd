class_name WorkoutResolution
extends RefCounted

const ResolvedWorkoutSet = preload("res://../data_types/resolved_workout_set.gd")

const REQUIRED_FIELDS := ["workoutId", "steps"]

# Canonical semantics:
# - the returned workoutId must match the source workout.
# - steps remain in workout order.
# - each resolved workout set represents one authored set selection.
# - each resolved workout set must include set/chart/song/environment identity plus chart feature+difficulty.
func resolve_workout(_workout: Dictionary, _registry: Variant) -> Dictionary:
	push_error("WorkoutResolution.resolve_workout must be implemented by a consumer.")
	return {}

static func validate_resolved_workout(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			issues.append({
				"code": "resolved_workout_missing_field",
				"message": "Resolved workout is missing required field '%s'." % field,
				"field": field,
			})
	var steps_value: Variant = data.get("steps", [])
	if data.has("steps") and not (steps_value is Array):
		issues.append({
			"code": "resolved_workout_steps_invalid_type",
			"message": "Resolved workout steps must be an array.",
		})
		return issues
	for index in range(steps_value.size()):
		var resolved_workout_set_value: Variant = steps_value[index]
		if not (resolved_workout_set_value is Dictionary):
			issues.append({
				"code": "resolved_workout_step_invalid_type",
				"message": "Resolved workout set entries must be dictionaries.",
				"index": index,
			})
			continue
		for field in ResolvedWorkoutSet.validate_shape(resolved_workout_set_value):
			issues.append({
				"code": "resolved_workout_step_missing_field",
				"message": "Resolved workout set is missing required field '%s'." % field,
				"field": field,
				"index": index,
				"stepId": String(resolved_workout_set_value.get("stepId", "")),
			})
	return issues
