extends RefCounted

const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/song_package_yaml_valid_splat")
	var retired_workout_alias_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/song_package_yaml_retired_workout_alias")
	var invalid_legacy_fields_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/song_package_yaml_invalid_legacy_fields")
	var missing_set_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/song_package_yaml_missing_set_ref")
	var valid_result := validator.validate_song_package_yaml_package(valid_fixture_path)
	var autodetect_result := validator.validate_fixture_package(valid_fixture_path)
	var retired_workout_alias_result := validator.validate_fixture_package(retired_workout_alias_fixture_path)
	var invalid_legacy_fields_result := validator.validate_song_package_yaml_package(invalid_legacy_fields_fixture_path)
	var missing_set_result := validator.validate_song_package_yaml_package(missing_set_fixture_path)
	var retired_workout_alias_codes := _sorted_issue_codes(retired_workout_alias_result)
	var invalid_legacy_codes := _sorted_issue_codes(invalid_legacy_fields_result)
	var missing_set_codes := _sorted_issue_codes(missing_set_result)
	var passed: bool = (
		valid_result.is_valid()
		and autodetect_result.is_valid()
		and retired_workout_alias_codes == ["retired_workout_yaml_root"]
		and invalid_legacy_codes == [
			"song_package_forbidden_field",
			"song_package_forbidden_field",
			"song_package_forbidden_field",
			"song_package_forbidden_field",
		]
		and missing_set_codes == ["missing_chart_ref"]
	)
	return {
		"name": "song_package_yaml_contract",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"autodetect": autodetect_result.to_dict(),
			"retiredWorkoutAlias": retired_workout_alias_result.to_dict(),
			"invalidLegacyFields": invalid_legacy_fields_result.to_dict(),
			"missingSet": missing_set_result.to_dict(),
		},
	}

static func _sorted_issue_codes(result) -> Array[String]:
	var codes: Array[String] = []
	for issue in result.issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
