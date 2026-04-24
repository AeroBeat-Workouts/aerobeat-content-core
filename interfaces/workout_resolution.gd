class_name WorkoutResolution
extends RefCounted

func resolve_workout(_workout: Dictionary, _registry: Variant) -> Dictionary:
	push_error("WorkoutResolution.resolve_workout must be implemented by a consumer.")
	return {}
