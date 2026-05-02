extends RefCounted

const Workout = preload("res://../data_types/workout.gd")
const WorkoutSet = preload("res://../data_types/workout_set.gd")

static func run() -> Dictionary:
	var missing_workout_set_fields := WorkoutSet.validate_shape({
	})
	var workout_set_order_issues := Workout.validate_set_order_shape({
		"setOrder": [
			"set_demo_boxing_round_01",
			"",
		]
	})
	var passed := (
		missing_workout_set_fields == ["setId"]
		and workout_set_order_issues.size() == 1
		and String(workout_set_order_issues[0].get("code", "")) == "workout_set_order_invalid_entry"
	)
	return {
		"name": "workout_set_contract",
		"passed": passed,
		"details": {
			"missingWorkoutSetFields": missing_workout_set_fields,
			"workoutSetOrderIssues": workout_set_order_issues,
		},
	}
