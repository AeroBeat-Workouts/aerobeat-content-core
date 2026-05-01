class_name EnvironmentRecord
extends RefCounted

const REQUIRED_FIELDS := ["schema", "environmentId", "environmentName", "type", "resourcePath"]
const VALID_TYPES := ["image_background", "video_background", "glb_environment"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var environment_type := String(data.get("type", ""))
	if not environment_type.is_empty() and not (environment_type in VALID_TYPES):
		issues.append({
			"code": "invalid_environment_type",
			"message": "Environment type must be one of image_background/video_background/glb_environment.",
			"field": "type",
		})
	return issues
