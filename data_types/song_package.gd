class_name SongPackage
extends RefCounted

const REQUIRED_FIELDS := ["schema", "songPackageId", "songPackageName", "setIds"]
const FORBIDDEN_FIELDS := ["workoutId", "workoutName", "coachConfigId", "setOrder"]

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
				"code": "song_package_forbidden_field",
				"message": "Song package field '%s' is legacy workout-era contract data and must not be present." % field,
				"field": field,
			})
	var set_ids_value: Variant = data.get("setIds", [])
	if data.has("setIds") and not (set_ids_value is Array):
		issues.append({
			"code": "song_package_set_ids_invalid_type",
			"message": "Song package setIds must be an array of set ids.",
			"field": "setIds",
		})
		return issues
	for index in range(set_ids_value.size()):
		var set_id_value: Variant = set_ids_value[index]
		if not (set_id_value is String) or String(set_id_value).strip_edges().is_empty():
			issues.append({
				"code": "song_package_set_ids_invalid_entry",
				"message": "Song package setIds entries must be non-empty set ids.",
				"field": "setIds[%d]" % index,
				"index": index,
			})
	return issues
