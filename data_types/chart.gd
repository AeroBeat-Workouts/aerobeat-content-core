class_name Chart
extends RefCounted

const ChartEnvelope = preload("res://addons/aerobeat-content-core/data_types/chart_envelope.gd")

const BOXING_LEGACY_TYPE_REPLACEMENTS := {
	"jab": "straight_left",
	"cross": "straight_right",
	"jab_left": "straight_left",
	"cross_right": "straight_right",
	"punch_left": "straight_left",
	"punch_right": "straight_right",
}

const BOXING_ALLOWED_TYPES := [
	"straight_left",
	"straight_right",
	"hook_left",
	"hook_right",
	"uppercut_left",
	"uppercut_right",
	"guard",
	"squat",
	"weave_left",
	"weave_right",
]
const BOXING_ALLOWED_TYPES_TEXT := "straight_left, straight_right, hook_left, hook_right, uppercut_left, uppercut_right, guard, squat, weave_left, weave_right"
const FLOW_ALLOWED_TYPES := ["burst"]
const FLOW_ALLOWED_TYPES_TEXT := "burst"
const FLOW_BURST_HAND_VALUES := ["left", "right"]

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
			continue
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
				issues.append_array(_validate_boxing_beat(beat, type, index))
			"flow":
				issues.append_array(_validate_flow_beat(beat, type, index))
	return issues

static func _validate_boxing_beat(beat: Dictionary, type: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if BOXING_LEGACY_TYPE_REPLACEMENTS.has(type):
		issues.append({
			"code": "invalid_boxing_type",
			"field": "beats[%d].type" % index,
			"index": index,
			"message": "Boxing beat type '%s' is legacy. Use '%s' to match the canonical authored chart contract." % [type, BOXING_LEGACY_TYPE_REPLACEMENTS[type]],
		})
	elif not (type in BOXING_ALLOWED_TYPES):
		issues.append({
			"code": "invalid_boxing_type",
			"field": "beats[%d].type" % index,
			"index": index,
			"message": "Boxing beat type '%s' is not part of the canonical authored chart contract. Allowed types: %s." % [type, BOXING_ALLOWED_TYPES_TEXT],
		})
	if beat.has("portal"):
		issues.append({
			"code": "invalid_boxing_portal",
			"field": "beats[%d].portal" % index,
			"index": index,
			"message": "Boxing beat portal fields are stale. Use semantic Boxing beat types without portal-based authored placement.",
		})
	if beat.has("end"):
		issues.append({
			"code": "invalid_boxing_end",
			"field": "beats[%d].end" % index,
			"index": index,
			"message": "Boxing beat end fields are stale. Only Flow burst beats may declare an end beat value.",
		})
	return issues

static func _validate_flow_beat(beat: Dictionary, type: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if beat.has("portal"):
		issues.append({
			"code": "invalid_flow_portal",
			"field": "beats[%d].portal" % index,
			"index": index,
			"message": "Flow beat portal fields are stale. The current Flow direction is direct calibrated 4x3 gameplay rather than portal-based authored placement.",
		})
	if not (type in FLOW_ALLOWED_TYPES):
		issues.append({
			"code": "invalid_flow_type",
			"field": "beats[%d].type" % index,
			"index": index,
			"message": "Flow beat type '%s' is not part of the canonical authored chart contract. Allowed types: %s." % [type, FLOW_ALLOWED_TYPES_TEXT],
		})
		return issues
	if not beat.has("end"):
		issues.append({
			"code": "flow_burst_missing_end",
			"field": "beats[%d].end" % index,
			"index": index,
			"message": "Flow burst beats must declare an end beat value.",
		})
	var hand := String(beat.get("hand", ""))
	if hand.is_empty():
		issues.append({
			"code": "flow_burst_missing_hand",
			"field": "beats[%d].hand" % index,
			"index": index,
			"message": "Flow burst beats must declare a hand.",
		})
	elif not (hand in FLOW_BURST_HAND_VALUES):
		issues.append({
			"code": "flow_burst_invalid_hand",
			"field": "beats[%d].hand" % index,
			"index": index,
			"message": "Flow burst hand must be 'left' or 'right'.",
		})
	if not beat.has("placement"):
		issues.append({
			"code": "flow_burst_missing_placement",
			"field": "beats[%d].placement" % index,
			"index": index,
			"message": "Flow burst beats must declare a head placement cell.",
		})
	elif not (beat.get("placement") is int):
		issues.append({
			"code": "flow_burst_invalid_placement",
			"field": "beats[%d].placement" % index,
			"index": index,
			"message": "Flow burst placement must be an integer cell value.",
		})
	if not beat.has("direction"):
		issues.append({
			"code": "flow_burst_missing_direction",
			"field": "beats[%d].direction" % index,
			"index": index,
			"message": "Flow burst beats must declare a head direction value.",
		})
	elif not (beat.get("direction") is int):
		issues.append({
			"code": "flow_burst_invalid_direction",
			"field": "beats[%d].direction" % index,
			"index": index,
			"message": "Flow burst direction must be an integer value.",
		})
	if not beat.has("tailPlacement"):
		issues.append({
			"code": "flow_burst_missing_tail_placement",
			"field": "beats[%d].tailPlacement" % index,
			"index": index,
			"message": "Flow burst beats must declare a tail placement cell.",
		})
	elif not (beat.get("tailPlacement") is int):
		issues.append({
			"code": "flow_burst_invalid_tail_placement",
			"field": "beats[%d].tailPlacement" % index,
			"index": index,
			"message": "Flow burst tailPlacement must be an integer cell value.",
		})
	if not beat.has("checkpointCount"):
		issues.append({
			"code": "flow_burst_missing_checkpoint_count",
			"field": "beats[%d].checkpointCount" % index,
			"index": index,
			"message": "Flow burst beats must declare a checkpointCount.",
		})
	elif not (beat.get("checkpointCount") is int) or int(beat.get("checkpointCount")) < 1:
		issues.append({
			"code": "flow_burst_invalid_checkpoint_count",
			"field": "beats[%d].checkpointCount" % index,
			"index": index,
			"message": "Flow burst checkpointCount must be a positive integer.",
		})
	if beat.has("spacingBias") and not _is_number(beat.get("spacingBias")):
		issues.append({
			"code": "flow_burst_invalid_spacing_bias",
			"field": "beats[%d].spacingBias" % index,
			"index": index,
			"message": "Flow burst spacingBias must be numeric when present.",
		})
	return issues

static func _is_number(value: Variant) -> bool:
	return value is int or value is float
