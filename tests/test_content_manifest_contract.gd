extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/package_minimal_boxing")
	var result := validator.validate_fixture_package(fixture_path)
	if not result.is_valid():
		return {
			"name": "content_manifest_contract",
			"passed": false,
			"details": result.to_dict(),
		}
	return {
		"name": "content_manifest_contract",
		"passed": true,
		"details": {
			"issues": [],
			"fixture": fixture_path,
		},
	}
