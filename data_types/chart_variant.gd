## Day-one contract file kept as chart_variant.gd to match the initial repo-shape doc.
## The broader docs are converging on the shorter durable term "Chart" for this slice.
class_name ChartVariant
extends RefCounted

const ChartEnvelope = preload("res://../data_types/chart_envelope.gd")

static func validate_shape(data: Dictionary) -> Array[String]:
	return ChartEnvelope.validate_shape(data)
