class_name Song
extends RefCounted

const REQUIRED_FIELDS := ["schema", "songId", "songName", "durationSec", "audio"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
