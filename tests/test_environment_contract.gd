extends RefCounted

const EnvironmentRecord = preload("res://addons/aerobeat-content-core/data_types/environment.gd")
const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var invalid_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/invalid_environment_type")
	var invalid_result := validator.validate_fixture_package(invalid_fixture_path)
	var issue_codes: Array[String] = []
	for issue in invalid_result.issues:
		issue_codes.append(String(issue.get("code", "")))
	issue_codes.sort()
	var recommended_splat_issues := EnvironmentRecord.validate_contract({
		"type": "splat",
		"resourcePath": "media/environments/demo.compressed.ply",
	})
	var compatible_ply_issues := EnvironmentRecord.validate_contract({
		"type": "splat",
		"resourcePath": "media/environments/demo.ply",
	})
	var compatible_splat_issues := EnvironmentRecord.validate_contract({
		"type": "splat",
		"resourcePath": "media/environments/demo.splat",
	})
	var compatible_sog_issues := EnvironmentRecord.validate_contract({
		"type": "splat",
		"resourcePath": "media/environments/demo.sog",
	})
	var unsupported_spz_issues := EnvironmentRecord.validate_contract({
		"type": "splat",
		"resourcePath": "media/environments/demo.spz",
	})
	var passed := (
		EnvironmentRecord.VALID_TYPES == ["image_background", "video_background", "glb_environment", "splat"]
		and EnvironmentRecord.RECOMMENDED_SPLAT_RESOURCE_SUFFIX == ".compressed.ply"
		and EnvironmentRecord.SUPPORTED_SPLAT_RESOURCE_SUFFIXES == [".compressed.ply", ".ply", ".splat", ".sog"]
		and recommended_splat_issues.is_empty()
		and compatible_ply_issues.is_empty()
		and compatible_splat_issues.is_empty()
		and compatible_sog_issues.is_empty()
		and unsupported_spz_issues.size() == 1
		and String(unsupported_spz_issues[0].get("code", "")) == "invalid_splat_resource_path"
		and issue_codes == ["invalid_environment_type"]
	)
	return {
		"name": "environment_contract",
		"passed": passed,
		"details": {
			"allowed": EnvironmentRecord.VALID_TYPES,
			"recommendedSplatSuffix": EnvironmentRecord.RECOMMENDED_SPLAT_RESOURCE_SUFFIX,
			"supportedSplatSuffixes": EnvironmentRecord.SUPPORTED_SPLAT_RESOURCE_SUFFIXES,
			"recommendedSplatIssues": recommended_splat_issues,
			"compatiblePlyIssues": compatible_ply_issues,
			"compatibleSplatIssues": compatible_splat_issues,
			"compatibleSogIssues": compatible_sog_issues,
			"unsupportedSpzIssues": unsupported_spz_issues,
			"invalidFixtureIssues": invalid_result.to_dict(),
		},
	}
