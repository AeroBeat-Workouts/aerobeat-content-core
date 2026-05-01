extends RefCounted

const Workout = preload("res://../data_types/workout.gd")
const WorkoutStep = preload("res://../data_types/workout_step.gd")

static func run() -> Dictionary:
	var missing_step_fields := WorkoutStep.validate_shape({
		"stepId": "step_001",
	})
	var workout_set_order_issues := Workout.validate_set_order_shape({
		"setOrder": [
			"set_demo_boxing_round_01",
			"",
		]
	})
	var passed := (
		missing_step_fields == ["setId"]
		and workout_set_order_issues.size() == 1
		and String(workout_set_order_issues[0].get("code", "")) == "workout_set_order_invalid_entry"
	)
	return {
		"name": "workout_step_contract",
		"passed": passed,
		"details": {
			"missingStepFields": missing_step_fields,
			"workoutSetOrderIssues": workout_set_order_issues,
		},
	}
