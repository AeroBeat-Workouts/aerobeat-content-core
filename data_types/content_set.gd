class_name ContentSet
extends RefCounted

const REQUIRED_FIELDS := ["schema", "setId", "setName", "songId", "chartId", "environmentId"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
