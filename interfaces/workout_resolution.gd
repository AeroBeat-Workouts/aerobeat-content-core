class_name WorkoutResolution
extends RefCounted

const ResolvedWorkoutSet = preload("res://../data_types/resolved_workout_set.gd")

const REQUIRED_FIELDS := ["workoutId", "sets"]

# Canonical semantics:
# - the returned workoutId must match the source workout.
# - sets remain in workout order.
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
	var sets_value: Variant = data.get("sets", [])
	if data.has("sets") and not (sets_value is Array):
		issues.append({
			"code": "resolved_workout_sets_invalid_type",
			"message": "Resolved workout sets must be an array.",
		})
		return issues
	for index in range(sets_value.size()):
		var resolved_workout_set_value: Variant = sets_value[index]
		if not (resolved_workout_set_value is Dictionary):
			issues.append({
				"code": "resolved_workout_set_invalid_type",
				"message": "Resolved workout set entries must be dictionaries.",
				"index": index,
			})
			continue
		for field in ResolvedWorkoutSet.validate_shape(resolved_workout_set_value):
			issues.append({
				"code": "resolved_workout_set_missing_field",
				"message": "Resolved workout set is missing required field '%s'." % field,
				"field": field,
				"index": index,
				"setId": String(resolved_workout_set_value.get("setId", "")),
			})
	return issues
