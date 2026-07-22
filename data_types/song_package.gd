class_name SongPackage
extends RefCounted

const REQUIRED_FIELDS := ["schema", "songPackageId", "songPackageName", "packageVersion", "song", "charts"]
const FORBIDDEN_FIELDS := ["workoutId", "workoutName", "coachConfigId", "setOrder"]
const REQUIRED_CHART_DESCRIPTOR_FIELDS := ["setId", "setName", "chartId", "path"]

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
	var song_value: Variant = data.get("song", null)
	if data.has("song") and not (song_value is Dictionary):
		issues.append({
			"code": "song_package_song_invalid_type",
			"message": "Song package song must be an embedded song dictionary.",
			"field": "song",
		})
	var charts_value: Variant = data.get("charts", [])
	if data.has("charts") and not (charts_value is Array):
		issues.append({
			"code": "song_package_charts_invalid_type",
			"message": "Song package charts must be an array of root chart descriptors.",
			"field": "charts",
		})
		return issues
	for index in range(charts_value.size()):
		var entry: Variant = charts_value[index]
		if not (entry is Dictionary):
			issues.append({
				"code": "song_package_chart_descriptor_invalid_type",
				"message": "Song package charts entries must be dictionaries.",
				"field": "charts[%d]" % index,
				"index": index,
			})
			continue
		var descriptor := Dictionary(entry)
		for field in REQUIRED_CHART_DESCRIPTOR_FIELDS:
			if not descriptor.has(field) or String(descriptor.get(field, "")).strip_edges().is_empty():
				issues.append({
					"code": "song_package_chart_descriptor_missing_field",
					"message": "Song package chart descriptor is missing required field '%s'." % field,
					"field": "charts[%d].%s" % [index, field],
					"index": index,
				})
	return issues
