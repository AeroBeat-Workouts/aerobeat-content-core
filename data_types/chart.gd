class_name Chart
extends RefCounted

const ChartEnvelope = preload("res://../data_types/chart_envelope.gd")

const BOXING_LEGACY_TYPE_REPLACEMENTS := {
	"jab": "punch_left",
	"cross": "punch_right",
	"jab_left": "punch_left",
	"cross_right": "punch_right",
}

const BOXING_AUTHORED_STANCE_TYPES := ["orthodox", "southpaw"]

static func validate_shape(data: Dictionary) -> Array[String]:
	return ChartEnvelope.validate_shape(data)

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var feature := String(data.get("feature", ""))
	var events_value: Variant = data.get("events", [])
	if not (events_value is Array):
		issues.append({
			"code": "chart_events_not_array",
			"field": "events",
			"message": "Chart events must be an array.",
		})
		return issues
	var events: Array = events_value
	for index in range(events.size()):
		var event_value: Variant = events[index]
		if not (event_value is Dictionary):
			issues.append({
				"code": "chart_event_not_object",
				"field": "events[%d]" % index,
				"index": index,
				"message": "Each chart event must be an object.",
			})
			continue
		var event: Dictionary = event_value
		if not event.has("beat"):
			issues.append({
				"code": "chart_event_missing_beat",
				"field": "events[%d].beat" % index,
				"index": index,
				"message": "Each chart event must declare a beat.",
			})
		var type := String(event.get("type", ""))
		if type.is_empty():
			issues.append({
				"code": "chart_event_missing_type",
				"field": "events[%d].type" % index,
				"index": index,
				"message": "Each chart event must declare a type.",
			})
			continue
		match feature:
			"boxing":
				issues.append_array(_validate_boxing_event(type, index))
			"flow":
				issues.append_array(_validate_flow_event(event, index))
	return issues

static func _validate_boxing_event(type: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if BOXING_LEGACY_TYPE_REPLACEMENTS.has(type):
		issues.append({
			"code": "invalid_boxing_type",
			"field": "events[%d].type" % index,
			"index": index,
			"message": "Boxing event type '%s' is legacy. Use '%s' to match the input-truth chart contract." % [type, BOXING_LEGACY_TYPE_REPLACEMENTS[type]],
		})
	elif type in BOXING_AUTHORED_STANCE_TYPES:
		issues.append({
			"code": "invalid_boxing_stance_event",
			"field": "events[%d].type" % index,
			"index": index,
			"message": "Boxing stance label '%s' is authored chart semantics, not a tracked input event." % type,
		})
	return issues

static func _validate_flow_event(event: Dictionary, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if event.has("placement") and not (event.get("placement") is int):
		issues.append({
			"code": "flow_event_invalid_placement",
			"field": "events[%d].placement" % index,
			"index": index,
			"message": "Flow event placement must be an integer pass-through location.",
		})
	if event.has("direction"):
		if not event.has("placement"):
			issues.append({
				"code": "flow_event_missing_placement",
				"field": "events[%d].direction" % index,
				"index": index,
				"message": "Flow direction is follow-through guidance and must not replace placement.",
			})
		if not (event.get("direction") is int):
			issues.append({
				"code": "flow_event_invalid_direction",
				"field": "events[%d].direction" % index,
				"index": index,
				"message": "Flow event direction must be an integer follow-through hint.",
			})
	return issues
