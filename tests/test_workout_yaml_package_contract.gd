extends RefCounted

const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/package_yaml_valid_splat")
	var invalid_environment_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/package_yaml_invalid_environment_type")
	var missing_environment_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/package_yaml_missing_environment_ref")
	var valid_result := validator.validate_workout_yaml_package(valid_fixture_path)
	var autodetect_result := validator.validate_fixture_package(valid_fixture_path)
	var invalid_environment_result := validator.validate_workout_yaml_package(invalid_environment_fixture_path)
	var missing_environment_result := validator.validate_workout_yaml_package(missing_environment_fixture_path)
	var invalid_codes := _sorted_issue_codes(invalid_environment_result)
	var missing_codes := _sorted_issue_codes(missing_environment_result)
	var passed: bool = (
		valid_result.is_valid()
		and autodetect_result.is_valid()
		and invalid_codes == ["invalid_environment_type"]
		and missing_codes == ["missing_environment_ref"]
	)
	return {
		"name": "workout_yaml_package_contract",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"autodetect": autodetect_result.to_dict(),
			"invalidEnvironment": invalid_environment_result.to_dict(),
			"missingEnvironment": missing_environment_result.to_dict(),
		},
	}

static func _sorted_issue_codes(result) -> Array[String]:
	var codes: Array[String] = []
	for issue in result.issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
