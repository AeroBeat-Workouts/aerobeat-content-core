class_name ContentMigration
extends RefCounted

func can_migrate(_schema_id: String, _target_version: int) -> bool:
	return false

func migrate(_document: Dictionary, _target_version: int) -> Dictionary:
	push_error("ContentMigration.migrate must be implemented by an adapter.")
	return {}
