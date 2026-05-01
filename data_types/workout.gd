class_name Workout
extends RefCounted

const REQUIRED_FIELDS := ["schema", "workoutId", "workoutName", "description", "coachConfigId", "setOrder"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_set_order_shape(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not data.has("setOrder"):
		return issues
	var set_order_value: Variant = data.get("setOrder")
	if not (set_order_value is Array):
		issues.append({
			"code": "workout_set_order_invalid_type",
			"message": "Workout setOrder must be an array of set ids.",
			"field": "setOrder",
		})
		return issues
	for index in range(set_order_value.size()):
		var set_id_value: Variant = set_order_value[index]
		if not (set_id_value is String) or String(set_id_value).strip_edges().is_empty():
			issues.append({
				"code": "workout_set_order_invalid_entry",
				"message": "Workout setOrder entries must be non-empty set ids.",
				"field": "setOrder[%d]" % index,
				"index": index,
			})
	return issues
