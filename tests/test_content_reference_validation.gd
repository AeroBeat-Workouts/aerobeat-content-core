extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_result := validator.validate_fixture_path("res://../fixtures/package_minimal_boxing")
	var invalid_result := validator.validate_fixture_path("res://../fixtures/invalid_missing_song_ref")
	assert(valid_result.is_valid())
	assert(not invalid_result.is_valid())
	assert(invalid_result.error_count() >= 1)
	return {
		"name": "test_content_reference_validation",
		"passed": true,
		"details": {
			"valid": valid_result.to_dict(),
			"invalid": invalid_result.to_dict(),
		}
	}
