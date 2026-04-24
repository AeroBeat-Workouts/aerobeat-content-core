extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://../fixtures/package_minimal_boxing")
	var mismatch_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_workout_step_song_mismatch")
	var duplicate_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_duplicate_workout_step_ids")
	var valid_result := validator.validate_fixture_package(valid_fixture_path)
	var mismatch_result := validator.validate_fixture_package(mismatch_fixture_path)
	var duplicate_result := validator.validate_fixture_package(duplicate_fixture_path)
	var mismatch_codes := _sorted_codes(mismatch_result.issues)
	var duplicate_codes := _sorted_codes(duplicate_result.issues)
	var passed := (
		valid_result.is_valid()
		and mismatch_codes == ["workout_step_song_mismatch"]
		and duplicate_codes == ["duplicate_workout_step_id"]
	)
	return {
		"name": "workout_resolution_validation",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"songMismatch": mismatch_result.to_dict(),
			"duplicateStepIds": duplicate_result.to_dict(),
		},
	}

static func _sorted_codes(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
