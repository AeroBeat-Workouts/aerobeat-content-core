class_name ChartEnvelope
extends RefCounted

var schema: String
var chart_id: String
var event_count: int
var events: Array[Dictionary]

func _init(data: Dictionary = {}) -> void:
	schema = data.get("schema", "")
	chart_id = data.get("chart_id", "")
	events = Array(data.get("events", []), TYPE_DICTIONARY, "", null)
	event_count = events.size()

func to_dict() -> Dictionary:
	return {
		"schema": schema,
		"chart_id": chart_id,
		"event_count": event_count,
		"events": events,
	}
