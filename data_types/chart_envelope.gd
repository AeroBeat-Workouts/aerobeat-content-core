class_name ChartEnvelope
extends RefCounted

const REQUIRED_FIELDS := [
	"schema",
	"chartId",
	"chartName",
	"feature",
	"difficulty",
	"beats",
]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing
