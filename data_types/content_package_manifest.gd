class_name ContentPackageManifest
extends RefCounted

const REQUIRED_FIELDS := ["schema", "packageId", "packageVersion", "songs", "charts", "sets", "workouts", "coaches", "environments"]
const FORBIDDEN_FIELDS := ["routines", "assets", "assetSelections"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func forbidden_fields_present(data: Dictionary) -> Array[String]:
	var present: Array[String] = []
	for field in FORBIDDEN_FIELDS:
		if data.has(field):
			present.append(field)
	return present
