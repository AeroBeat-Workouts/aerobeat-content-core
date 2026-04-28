extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://../fixtures/package_minimal_boxing")
	var invalid_bpm_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_song_timing_bpm_shortcut")
	var invalid_stop_segment_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_song_stop_segment_missing_duration")
	var valid_result := validator.validate_fixture_package(valid_fixture_path)
	var invalid_bpm_result := validator.validate_fixture_package(invalid_bpm_fixture_path)
	var invalid_stop_segment_result := validator.validate_fixture_package(invalid_stop_segment_fixture_path)
	var invalid_bpm_codes := _sorted_codes(invalid_bpm_result.issues)
	var invalid_stop_segment_codes := _sorted_codes(invalid_stop_segment_result.issues)
	var passed := (
		valid_result.is_valid()
		and invalid_bpm_codes == [
			"song_tempo_segment_missing_field",
			"song_time_signature_segment_missing_field",
			"song_timing_bpm_shortcut_forbidden",
		]
		and invalid_stop_segment_codes == [
			"song_stop_segment_missing_field",
		]
	)
	return {
		"name": "song_timing_validation",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"invalidBpmShortcut": invalid_bpm_result.to_dict(),
			"invalidStopSegment": invalid_stop_segment_result.to_dict(),
		},
	}

static func _sorted_codes(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
