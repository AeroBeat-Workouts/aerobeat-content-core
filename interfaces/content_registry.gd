class_name ContentRegistry
extends RefCounted

const ContentReference = preload("res://../data_types/content_reference.gd")
const ContentQuery = preload("res://../data_types/content_query.gd")

func find_by_id(_reference: ContentReference) -> Dictionary:
	push_error("ContentRegistry.find_by_id must be implemented by an adapter.")
	return {}

func query(_content_query: ContentQuery) -> Array[Dictionary]:
	push_error("ContentRegistry.query must be implemented by an adapter.")
	return []
