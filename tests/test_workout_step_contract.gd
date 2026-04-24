extends RefCounted

const Workout = preload("res://../data_types/workout.gd")
const WorkoutStep = preload("res://../data_types/workout_step.gd")

static func run() -> Dictionary:
	var missing_step_fields := WorkoutStep.validate_shape({
		"stepId": "step_001",
	})
	var workout_step_issues := Workout.validate_steps_shape({
		"steps": [
			{
				"stepId": "step_001",
			},
			"not_a_dictionary",
		]
	})
	var passed := (
		missing_step_fields == ["chartId"]
		and workout_step_issues.size() == 2
		and String(workout_step_issues[0].get("code", "")) == "workout_step_missing_field"
		and String(workout_step_issues[1].get("code", "")) == "workout_step_invalid_type"
	)
	return {
		"name": "workout_step_contract",
		"passed": passed,
		"details": {
			"missingStepFields": missing_step_fields,
			"workoutStepIssues": workout_step_issues,
		},
	}
