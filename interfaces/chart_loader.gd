class_name ChartLoader
extends RefCounted

const ContentReference = preload("res://../data_types/content_reference.gd")
const ChartVariant = preload("res://../data_types/chart_variant.gd")

func load_chart(_reference: ContentReference) -> ChartVariant:
	push_error("ChartLoader.load_chart must be implemented by an adapter.")
	return null
