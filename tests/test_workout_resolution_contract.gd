extends RefCounted

const WorkoutResolution = preload("res://../interfaces/workout_resolution.gd")

class FakeWorkoutResolution:
	extends WorkoutResolution

	func resolve_workout(workout: Dictionary, registry: Variant) -> Dictionary:
		var charts_by_id: Dictionary = registry
		var resolved_steps: Array[Dictionary] = []
		for step in workout.get("steps", []):
			var chart: Dictionary = charts_by_id.get(String(step.get("chartId", "")), {})
			resolved_steps.append({
				"stepId": String(step.get("stepId", "")),
				"chartId": String(step.get("chartId", "")),
				"songId": String(chart.get("songId", "")),
				"routineId": String(chart.get("routineId", "")),
				"feature": String(chart.get("feature", "")),
				"difficulty": String(chart.get("difficulty", "")),
			})
		return {
			"workoutId": String(workout.get("workoutId", "")),
			"steps": resolved_steps,
		}

static func run() -> Dictionary:
	var resolver := FakeWorkoutResolution.new()
	var workout := {
		"workoutId": "workout_demo_boxing",
		"steps": [
			{
				"stepId": "step_001",
				"chartId": "chart_demo_boxing_medium",
			}
		]
	}
	var chart_registry := {
		"chart_demo_boxing_medium": {
			"chartId": "chart_demo_boxing_medium",
			"songId": "song_demo",
			"routineId": "routine_demo_boxing",
			"feature": "boxing",
			"difficulty": "medium",
		}
	}
	var resolved: Dictionary = resolver.resolve_workout(workout, chart_registry)
	var validation_issues := WorkoutResolution.validate_resolved_workout(resolved)
	var passed: bool = (
		String(resolved.get("workoutId", "")) == "workout_demo_boxing"
		and resolved.get("steps", []).size() == 1
		and String(resolved["steps"][0].get("stepId", "")) == "step_001"
		and String(resolved["steps"][0].get("songId", "")) == "song_demo"
		and validation_issues.is_empty()
	)
	return {
		"name": "workout_resolution_contract",
		"passed": passed,
		"details": {
			"resolved": resolved,
			"validationIssues": validation_issues,
		},
	}
