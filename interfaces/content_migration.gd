class_name ContentMigration
extends RefCounted

func can_migrate(_schema_id: String, _target_schema_id: String) -> bool:
	return false

func migrate_record(_record: Dictionary, _target_schema_id: String) -> Dictionary:
	push_error("ContentMigration.migrate_record must be implemented by a consumer.")
	return {}
