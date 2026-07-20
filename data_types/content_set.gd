class_name ContentSet
extends RefCounted

const REQUIRED_FIELDS := ["schema", "setId", "setName", "songId", "chartId"]
const FORBIDDEN_FIELDS := ["environmentId", "coachingOverlayId"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	for field in FORBIDDEN_FIELDS:
		if data.has(field):
			issues.append({
				"code": "set_forbidden_field",
				"message": "Set field '%s' is retired from the default imported song-package contract." % field,
				"field": field,
			})
	return issues
