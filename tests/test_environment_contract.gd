extends RefCounted

const EnvironmentRecord = preload("res://../data_types/environment.gd")
const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var invalid_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_environment_type")
	var invalid_result := validator.validate_fixture_package(invalid_fixture_path)
	var issue_codes: Array[String] = []
	for issue in invalid_result.issues:
		issue_codes.append(String(issue.get("code", "")))
	issue_codes.sort()
	var passed := (
		EnvironmentRecord.VALID_TYPES == ["image_background", "video_background", "glb_environment", "splat"]
		and EnvironmentRecord.validate_contract({"type": "splat"}).is_empty()
		and issue_codes == ["invalid_environment_type"]
	)
	return {
		"name": "environment_contract",
		"passed": passed,
		"details": {
			"allowed": EnvironmentRecord.VALID_TYPES,
			"splatIssues": EnvironmentRecord.validate_contract({"type": "splat"}),
			"invalidFixtureIssues": invalid_result.to_dict(),
		},
	}
