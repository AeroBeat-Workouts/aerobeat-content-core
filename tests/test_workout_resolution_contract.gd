extends RefCounted

const WorkoutResolution = preload("res://../interfaces/workout_resolution.gd")

class FakeWorkoutResolution:
	extends WorkoutResolution

	func resolve_workout(workout: Dictionary, _registry: Variant) -> Dictionary:
		var resolved_steps: Array[Dictionary] = []
		for step in workout.get("steps", []):
			resolved_steps.append({
				"chartId": String(step.get("chartId", "")),
				"songId": String(step.get("songId", "")),
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
				"chartId": "chart_demo_boxing_medium",
				"songId": "song_demo",
			}
		]
	}
	var resolved: Dictionary = resolver.resolve_workout(workout, null)
	var passed: bool = (
		String(resolved.get("workoutId", "")) == "workout_demo_boxing"
		and resolved.get("steps", []).size() == 1
		and String(resolved["steps"][0].get("chartId", "")) == "chart_demo_boxing_medium"
	)
	return {
		"name": "workout_resolution_contract",
		"passed": passed,
		"details": resolved,
	}
