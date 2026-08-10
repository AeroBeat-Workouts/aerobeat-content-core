extends RefCounted

const ContentMode = preload("res://addons/aerobeat-content-core/globals/content_mode.gd")
const ContentPackageValidatorScript = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidatorScript.new()
	var fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/invalid_chart_mode_dance")
	var result := validator.validate_fixture_package(fixture_path)
	var codes: Array[String] = []
	for issue in result.issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	var passed: bool = (
		ContentMode.ALL == ["boxing", "flow"]
		and ContentMode.is_valid("boxing")
		and ContentMode.is_valid("flow")
		and not ContentMode.is_valid("dance")
		and not ContentMode.is_valid("step")
		and codes == ["invalid_mode"]
	)
	return {
		"name": "content_mode_contract",
		"passed": passed,
		"details": {
			"allowed": ContentMode.ALL,
			"danceValid": ContentMode.is_valid("dance"),
			"stepValid": ContentMode.is_valid("step"),
			"validatorIssues": result.to_dict(),
		},
	}
