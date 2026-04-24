class_name WorkoutResolution
extends RefCounted

const Workout = preload("res://../data_types/workout.gd")
const ContentRegistry = preload("res://../interfaces/content_registry.gd")

func resolve_step(_workout: Workout, _step_index: int, _registry: ContentRegistry) -> Dictionary:
	push_error("WorkoutResolution.resolve_step must be implemented by an adapter.")
	return {}
