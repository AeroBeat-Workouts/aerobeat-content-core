extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_legacy_manifest_fields")
	var result := validator.validate_fixture_package(fixture_path)
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
		"name": "legacy_package_contract",
		"passed": passed,
		"details": result.to_dict(),
	}
