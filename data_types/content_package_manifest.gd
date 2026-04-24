class_name ContentPackageManifest
extends RefCounted

const REQUIRED_FIELDS := ["schema", "packageId", "packageVersion", "songs", "routines", "charts", "workouts"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
