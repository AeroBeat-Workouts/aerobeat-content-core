class_name Chart
extends RefCounted

const ChartEnvelope = preload("res://../data_types/chart_envelope.gd")

const BOXING_LEGACY_TYPE_REPLACEMENTS := {
	"jab": "punch_left",
	"cross": "hook_right",
	"jab_left": "punch_left",
	"cross_right": "hook_right",
}

const BOXING_AUTHORED_STANCE_TYPES := ["orthodox", "southpaw"]

static func validate_shape(data: Dictionary) -> Array[String]:
	return ChartEnvelope.validate_shape(data)

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var feature := String(data.get("feature", ""))
	var beats_value: Variant = data.get("beats", [])
	if not (beats_value is Array):
		issues.append({
			"code": "chart_beats_not_array",
			"field": "beats",
			"message": "Chart beats must be an array.",
		})
		return issues
	var beats: Array = beats_value
	for index in range(beats.size()):
		var beat_value: Variant = beats[index]
		if not (beat_value is Dictionary):
			issues.append({
				"code": "chart_beat_not_object",
				"field": "beats[%d]" % index,
				"index": index,
				"message": "Each chart beat must be an object.",
			})
			continue
		var beat: Dictionary = beat_value
		if not beat.has("start"):
			issues.append({
				"code": "chart_beat_missing_start",
				"field": "beats[%d].start" % index,
				"index": index,
				"message": "Each chart beat must declare a start beat value.",
			})
		elif not _is_number(beat.get("start")):
			issues.append({
				"code": "chart_beat_invalid_start",
				"field": "beats[%d].start" % index,
				"index": index,
				"message": "Chart beat start must be numeric.",
			})
		if beat.has("end") and not _is_number(beat.get("end")):
			issues.append({
				"code": "chart_beat_invalid_end",
				"field": "beats[%d].end" % index,
				"index": index,
				"message": "Chart beat end must be numeric when present.",
			})
		var type := String(beat.get("type", ""))
		if type.is_empty():
			issues.append({
				"code": "chart_beat_missing_type",
				"field": "beats[%d].type" % index,
				"index": index,
				"message": "Each chart beat must declare a type.",
			})
			continue
		match feature:
			"boxing":
				issues.append_array(_validate_boxing_beat(type, index))
			"flow":
				issues.append_array(_validate_flow_beat(beat, index))
	return issues

static func _validate_boxing_beat(type: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if BOXING_LEGACY_TYPE_REPLACEMENTS.has(type):
		issues.append({
			"code": "invalid_boxing_type",
			"field": "beats[%d].type" % index,
			"index": index,
			"message": "Boxing beat type '%s' is legacy. Use '%s' to match the canonical authored chart contract." % [type, BOXING_LEGACY_TYPE_REPLACEMENTS[type]],
		})
	elif type in BOXING_AUTHORED_STANCE_TYPES:
		pass
	return issues

static func _validate_flow_beat(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if beat.has("placement") and not (beat.get("placement") is int):
		issues.append({
			"code": "flow_beat_invalid_placement",
			"field": "beats[%d].placement" % index,
			"index": index,
			"message": "Flow beat placement must be an integer pass-through location.",
		})
	if beat.has("direction"):
		if not beat.has("placement"):
			issues.append({
				"code": "flow_beat_missing_placement",
				"field": "beats[%d].direction" % index,
				"index": index,
				"message": "Flow direction is follow-through guidance and must not replace placement.",
			})
		if not (beat.get("direction") is int):
			issues.append({
				"code": "flow_beat_invalid_direction",
				"field": "beats[%d].direction" % index,
				"index": index,
				"message": "Flow beat direction must be an integer follow-through hint.",
			})
	return issues

static func _is_number(value: Variant) -> bool:
	return value is int or value is float
