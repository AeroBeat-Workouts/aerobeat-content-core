extends RefCounted

const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/invalid_legacy_manifest_fields")
	var result := validator.validate_legacy_manifest_fixture_package(fixture_path)
	var codes: Array[String] = []
	for issue in result.issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	var passed := (
		not result.is_valid()
		and codes == [
			"manifest_forbidden_field",
			"manifest_forbidden_field",
			"manifest_forbidden_field",
		]
	)
	return {
		"name": "legacy_manifest_field_rejection",
		"passed": passed,
		"details": result.to_dict(),
	}
