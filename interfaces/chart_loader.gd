class_name ChartLoader
extends RefCounted

func load_chart_by_reference(_reference: Dictionary) -> Dictionary:
	push_error("ChartLoader.load_chart_by_reference must be implemented by a consumer.")
	return {}
