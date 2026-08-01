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
const FLOW_ALLOWED_TYPES := ["note", "burst", "bomb", "obstacle", "arc"]
const FLOW_ALLOWED_TYPES_TEXT := "note, burst, bomb, obstacle, arc"
const FLOW_HAND_VALUES := ["left", "right"]

static func validate_shape(data: Dictionary) -> Array[String]:
	return ChartEnvelope.validate_shape(data)

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var mode := String(data.get("mode", ""))
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
		match mode:
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
			"message": "Boxing beat end fields are stale. Only Flow burst, obstacle, and arc beats may declare an end beat value.",
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
	match type:
		"note":
			issues.append_array(_validate_flow_note(beat, index))
		"burst":
			issues.append_array(_validate_flow_burst(beat, index))
		"bomb":
			issues.append_array(_validate_flow_bomb(beat, index))
		"obstacle":
			issues.append_array(_validate_flow_obstacle(beat, index))
		"arc":
			issues.append_array(_validate_flow_arc(beat, index))
	return issues

static func _validate_flow_note(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	issues.append_array(_require_flow_hand(beat, index, "flow_note"))
	issues.append_array(_require_flow_int_field(beat, "placement", index, "flow_note", "placement cell"))
	if not beat.has("requiresDirection"):
		issues.append(_issue("flow_note_missing_requires_direction", "beats[%d].requiresDirection" % index, index, "Flow note beats must declare requiresDirection."))
	elif not (beat.get("requiresDirection") is bool):
		issues.append(_issue("flow_note_invalid_requires_direction", "beats[%d].requiresDirection" % index, index, "Flow note requiresDirection must be a boolean."))
	else:
		var requires_direction := bool(beat.get("requiresDirection"))
		if requires_direction and not beat.has("direction"):
			issues.append(_issue("flow_note_missing_direction", "beats[%d].direction" % index, index, "Flow note beats with requiresDirection=true must declare a direction."))
		elif requires_direction and not (beat.get("direction") is int):
			issues.append(_issue("flow_note_invalid_direction", "beats[%d].direction" % index, index, "Flow note direction must be an integer value when required."))
		elif not requires_direction and beat.has("direction"):
			issues.append(_issue("flow_note_unexpected_direction", "beats[%d].direction" % index, index, "Flow note beats with requiresDirection=false must not declare a direction."))
	if beat.has("angleOffset") and not _is_number(beat.get("angleOffset")):
		issues.append(_issue("flow_note_invalid_angle_offset", "beats[%d].angleOffset" % index, index, "Flow note angleOffset must be numeric when present."))
	return issues

static func _validate_flow_burst(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not beat.has("end"):
		issues.append(_issue("flow_burst_missing_end", "beats[%d].end" % index, index, "Flow burst beats must declare an end beat value."))
	issues.append_array(_require_flow_hand(beat, index, "flow_burst"))
	issues.append_array(_require_flow_int_field(beat, "placement", index, "flow_burst", "head placement cell"))
	issues.append_array(_require_flow_int_field(beat, "direction", index, "flow_burst", "head direction value"))
	issues.append_array(_require_flow_int_field(beat, "tailPlacement", index, "flow_burst", "tail placement cell"))
	if not beat.has("checkpointCount"):
		issues.append(_issue("flow_burst_missing_checkpoint_count", "beats[%d].checkpointCount" % index, index, "Flow burst beats must declare a checkpointCount."))
	elif not (beat.get("checkpointCount") is int) or int(beat.get("checkpointCount")) < 1:
		issues.append(_issue("flow_burst_invalid_checkpoint_count", "beats[%d].checkpointCount" % index, index, "Flow burst checkpointCount must be a positive integer."))
	if beat.has("spacingBias") and not _is_number(beat.get("spacingBias")):
		issues.append(_issue("flow_burst_invalid_spacing_bias", "beats[%d].spacingBias" % index, index, "Flow burst spacingBias must be numeric when present."))
	return issues

static func _validate_flow_bomb(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	issues.append_array(_require_flow_int_field(beat, "placement", index, "flow_bomb", "placement cell"))
	if beat.has("end"):
		issues.append(_issue("flow_bomb_unexpected_end", "beats[%d].end" % index, index, "Flow bomb beats must not declare an end beat value."))
	return issues

static func _validate_flow_obstacle(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not beat.has("end"):
		issues.append(_issue("flow_obstacle_missing_end", "beats[%d].end" % index, index, "Flow obstacle beats must declare an end beat value."))
	if not beat.has("cells"):
		issues.append(_issue("flow_obstacle_missing_cells", "beats[%d].cells" % index, index, "Flow obstacle beats must declare occupied cells."))
	elif not (beat.get("cells") is Array):
		issues.append(_issue("flow_obstacle_invalid_cells", "beats[%d].cells" % index, index, "Flow obstacle cells must be an array of integer cell values."))
	else:
		var cells: Array = beat.get("cells", [])
		if cells.is_empty():
			issues.append(_issue("flow_obstacle_empty_cells", "beats[%d].cells" % index, index, "Flow obstacle cells must not be empty."))
		else:
			for cell_index in range(cells.size()):
				if not (cells[cell_index] is int):
					issues.append(_issue("flow_obstacle_invalid_cell", "beats[%d].cells[%d]" % [index, cell_index], index, "Flow obstacle cells must contain only integer cell values."))
	return issues

static func _validate_flow_arc(beat: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not beat.has("end"):
		issues.append(_issue("flow_arc_missing_end", "beats[%d].end" % index, index, "Flow arc beats must declare an end beat value."))
	issues.append_array(_require_flow_hand(beat, index, "flow_arc"))
	issues.append_array(_require_flow_int_field(beat, "startPlacement", index, "flow_arc", "start placement cell"))
	issues.append_array(_require_flow_int_field(beat, "endPlacement", index, "flow_arc", "end placement cell"))
	issues.append_array(_require_flow_int_field(beat, "startDirection", index, "flow_arc", "start direction value"))
	issues.append_array(_require_flow_int_field(beat, "endDirection", index, "flow_arc", "end direction value"))
	issues.append_array(_require_flow_numeric_field(beat, "headCurveMultiplier", index, "flow_arc", "headCurveMultiplier"))
	issues.append_array(_require_flow_numeric_field(beat, "tailCurveMultiplier", index, "flow_arc", "tailCurveMultiplier"))
	issues.append_array(_require_flow_int_field(beat, "midAnchorMode", index, "flow_arc", "midAnchorMode"))
	if beat.has("startNoteRef") and not _is_non_empty_string(beat.get("startNoteRef")):
		issues.append(_issue("flow_arc_invalid_start_note_ref", "beats[%d].startNoteRef" % index, index, "Flow arc startNoteRef must be a non-empty string when present."))
	if beat.has("endNoteRef") and not _is_non_empty_string(beat.get("endNoteRef")):
		issues.append(_issue("flow_arc_invalid_end_note_ref", "beats[%d].endNoteRef" % index, index, "Flow arc endNoteRef must be a non-empty string when present."))
	return issues

static func _require_flow_hand(beat: Dictionary, index: int, prefix: String) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var hand := String(beat.get("hand", ""))
	if hand.is_empty():
		issues.append(_issue("%s_missing_hand" % prefix, "beats[%d].hand" % index, index, "Flow %s beats must declare a hand." % prefix.trim_prefix("flow_")))
	elif not (hand in FLOW_HAND_VALUES):
		issues.append(_issue("%s_invalid_hand" % prefix, "beats[%d].hand" % index, index, "Flow %s hand must be 'left' or 'right'." % prefix.trim_prefix("flow_")))
	return issues

static func _require_flow_int_field(beat: Dictionary, field_name: String, index: int, prefix: String, label: String) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not beat.has(field_name):
		issues.append(_issue("%s_missing_%s" % [prefix, _snake_field_name(field_name)], "beats[%d].%s" % [index, field_name], index, "Flow %s beats must declare a %s." % [prefix.trim_prefix("flow_"), label]))
	elif not (beat.get(field_name) is int):
		issues.append(_issue("%s_invalid_%s" % [prefix, _snake_field_name(field_name)], "beats[%d].%s" % [index, field_name], index, "Flow %s %s must be an integer value." % [prefix.trim_prefix("flow_"), field_name]))
	return issues

static func _require_flow_numeric_field(beat: Dictionary, field_name: String, index: int, prefix: String, label: String) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not beat.has(field_name):
		issues.append(_issue("%s_missing_%s" % [prefix, _snake_field_name(field_name)], "beats[%d].%s" % [index, field_name], index, "Flow %s beats must declare %s." % [prefix.trim_prefix("flow_"), label]))
	elif not _is_number(beat.get(field_name)):
		issues.append(_issue("%s_invalid_%s" % [prefix, _snake_field_name(field_name)], "beats[%d].%s" % [index, field_name], index, "Flow %s %s must be numeric." % [prefix.trim_prefix("flow_"), field_name]))
	return issues

static func _issue(code: String, field: String, index: int, message: String) -> Dictionary:
	return {
		"code": code,
		"field": field,
		"index": index,
		"message": message,
	}

static func _snake_field_name(field_name: String) -> String:
	var snake := ""
	for character in field_name:
		var char_text := String(character)
		if char_text == char_text.to_upper() and not snake.is_empty():
			snake += "_"
		snake += char_text.to_lower()
	return snake

static func _is_non_empty_string(value: Variant) -> bool:
	return value is String and String(value).strip_edges() != ""

static func _is_number(value: Variant) -> bool:
	return value is int or value is float
