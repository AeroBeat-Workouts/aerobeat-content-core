class_name EnvironmentRecord
extends RefCounted

const REQUIRED_FIELDS := ["schema", "environmentId", "environmentName", "type", "resourcePath"]
const VALID_TYPES := ["image_background", "video_background", "glb_environment", "splat"]
const RECOMMENDED_SPLAT_RESOURCE_SUFFIX := ".compressed.ply"
const SUPPORTED_SPLAT_RESOURCE_SUFFIXES := [RECOMMENDED_SPLAT_RESOURCE_SUFFIX, ".ply", ".splat", ".sog"]

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
			"message": "Environment type must be one of image_background/video_background/glb_environment/splat.",
			"field": "type",
		})
	if environment_type == "splat":
		var resource_path := String(data.get("resourcePath", "")).to_lower()
		if not resource_path.is_empty() and not _has_supported_splat_resource_suffix(resource_path):
			issues.append({
				"code": "invalid_splat_resource_path",
				"message": "Splat resourcePath must use the recommended .compressed.ply format or a GDGS compatibility-supported .ply/.splat/.sog asset. .spz is not supported.",
				"field": "resourcePath",
			})
	return issues

static func _has_supported_splat_resource_suffix(resource_path: String) -> bool:
	for suffix in SUPPORTED_SPLAT_RESOURCE_SUFFIXES:
		if resource_path.ends_with(String(suffix)):
			return true
	return false
