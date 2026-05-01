extends RefCounted

const ContentFeature = preload("res://../globals/content_feature.gd")
const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_chart_feature_dance")
	var result := validator.validate_fixture_package(fixture_path)
	var codes: Array[String] = []
	for issue in result.issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	var passed := (
		ContentFeature.ALL == ["boxing", "flow"]
		and ContentFeature.is_valid("boxing")
		and ContentFeature.is_valid("flow")
		and not ContentFeature.is_valid("dance")
		and not ContentFeature.is_valid("step")
		and codes == ["invalid_feature"]
	)
	return {
		"name": "content_feature_contract",
		"passed": passed,
		"details": {
			"allowed": ContentFeature.ALL,
			"danceValid": ContentFeature.is_valid("dance"),
			"stepValid": ContentFeature.is_valid("step"),
			"validatorIssues": result.to_dict(),
		},
	}
