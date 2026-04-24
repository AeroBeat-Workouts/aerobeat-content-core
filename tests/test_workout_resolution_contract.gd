extends RefCounted

const ContentRegistry = preload("res://../interfaces/content_registry.gd")
const WorkoutResolution = preload("res://../interfaces/workout_resolution.gd")
const Workout = preload("res://../data_types/workout.gd")
const ContentReference = preload("res://../data_types/content_reference.gd")
const ContentMode = preload("res://../globals/content_mode.gd")
const ContentDifficulty = preload("res://../globals/content_difficulty.gd")

class StaticRegistry:
	extends "res://../interfaces/content_registry.gd"
	var by_id: Dictionary
	func _init(p_by_id: Dictionary) -> void:
		by_id = p_by_id
	func find_by_id(reference) -> Dictionary:
		return by_id.get(reference.key(), {})

class StaticWorkoutResolution:
	extends "res://../interfaces/workout_resolution.gd"
	func resolve_step(workout, step_index: int, registry) -> Dictionary:
		var step: Dictionary = workout.steps[step_index]
		var chart_ref := ContentReference.new("chart", step.get("chart_id", ""))
		return {
			"step": step_index,
			"chart": registry.find_by_id(chart_ref),
		}

static func run() -> Dictionary:
	var workout := Workout.new({
		"id": "workout.demo",
		"title": "Demo Workout",
		"mode": ContentMode.BOXING,
		"steps": [{"chart_id": "chart.demo_boxing.medium"}],
	})
	var registry := StaticRegistry.new({
		"chart:chart.demo_boxing.medium": {"id": "chart.demo_boxing.medium", "difficulty": ContentDifficulty.MEDIUM}
	})
	var resolution := StaticWorkoutResolution.new()
	var resolved := resolution.resolve_step(workout, 0, registry)
	assert(resolved["chart"]["id"] == "chart.demo_boxing.medium")
	return {
		"name": "test_workout_resolution_contract",
		"passed": true,
		"details": resolved,
	}
