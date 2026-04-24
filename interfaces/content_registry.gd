class_name ContentRegistry
extends RefCounted

func find_by_id(_kind: String, _id: String) -> Dictionary:
	push_error("ContentRegistry.find_by_id must be implemented by a consumer.")
	return {}

func query(_content_query: Dictionary) -> Array[Dictionary]:
	push_error("ContentRegistry.query must be implemented by a consumer.")
	return []
