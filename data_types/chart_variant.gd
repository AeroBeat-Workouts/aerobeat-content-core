class_name ChartVariant
extends RefCounted

const ChartEnvelope = preload("res://../data_types/chart_envelope.gd")

var id: String
var routine_id: String
var difficulty: String
var interaction_family: String
var chart_envelope: ChartEnvelope

func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	routine_id = data.get("routine_id", "")
	difficulty = data.get("difficulty", "")
	interaction_family = data.get("interaction_family", "")
	chart_envelope = ChartEnvelope.new(data.get("chart_envelope", {}))

func to_dict() -> Dictionary:
	return {
		"id": id,
		"routine_id": routine_id,
		"difficulty": difficulty,
		"interaction_family": interaction_family,
		"chart_envelope": chart_envelope.to_dict(),
	}
