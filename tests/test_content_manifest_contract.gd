extends RefCounted

const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/package_minimal_boxing")
	var result := validator.validate_legacy_manifest_fixture_package(fixture_path)
	if not result.is_valid():
		return {
			"name": "legacy_manifest_fixture_contract",
			"passed": false,
			"details": result.to_dict(),
		}
	return {
		"name": "legacy_manifest_fixture_contract",
		"passed": true,
		"details": {
			"issues": [],
			"fixture": fixture_path,
		},
	}
