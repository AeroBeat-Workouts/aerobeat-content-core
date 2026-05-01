extends RefCounted

const WorkoutResolution = preload("res://../interfaces/workout_resolution.gd")

class FakeWorkoutResolution:
	extends WorkoutResolution

	func resolve_workout(workout: Dictionary, registry: Variant) -> Dictionary:
		var sets_by_id: Dictionary = registry.get("sets", {})
		var charts_by_id: Dictionary = registry.get("charts", {})
		var resolved_steps: Array[Dictionary] = []
		var set_order: Array = workout.get("setOrder", [])
		for index in range(set_order.size()):
			var set_id := String(set_order[index])
			var set_data: Dictionary = sets_by_id.get(set_id, {})
			var chart: Dictionary = charts_by_id.get(String(set_data.get("chartId", "")), {})
			resolved_steps.append({
				"stepId": "step_%03d" % [index + 1],
				"setId": set_id,
				"chartId": String(set_data.get("chartId", "")),
				"songId": String(set_data.get("songId", "")),
				"environmentId": String(set_data.get("environmentId", "")),
				"coachingOverlayId": String(set_data.get("coachingOverlayId", "")),
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
		"setOrder": ["set_demo_boxing_round_01"]
	}
	var registry := {
		"sets": {
			"set_demo_boxing_round_01": {
				"setId": "set_demo_boxing_round_01",
				"chartId": "chart_demo_boxing_medium",
				"songId": "song_demo",
				"environmentId": "environment_demo_gym",
				"coachingOverlayId": "overlay_demo_round_01",
			}
		},
		"charts": {
			"chart_demo_boxing_medium": {
				"chartId": "chart_demo_boxing_medium",
				"feature": "boxing",
				"difficulty": "medium",
			}
		}
	}
	var resolved: Dictionary = resolver.resolve_workout(workout, registry)
	var validation_issues := WorkoutResolution.validate_resolved_workout(resolved)
	var passed: bool = (
		String(resolved.get("workoutId", "")) == "workout_demo_boxing"
		and resolved.get("steps", []).size() == 1
		and String(resolved["steps"][0].get("setId", "")) == "set_demo_boxing_round_01"
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
