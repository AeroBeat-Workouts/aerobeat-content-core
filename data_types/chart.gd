class_name Chart
extends RefCounted

const ChartEnvelope = preload("res://../data_types/chart_envelope.gd")

static func validate_shape(data: Dictionary) -> Array[String]:
	return ChartEnvelope.validate_shape(data)
