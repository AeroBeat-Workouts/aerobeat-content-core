extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_missing_song_ref")
	var result := validator.validate_fixture_package(fixture_path)
	var saw_missing_song := false
	for issue in result.issues:
		if String(issue.get("code", "")) == "missing_song_ref":
			saw_missing_song = true
			break
	return {
		"name": "content_reference_validation",
		"passed": saw_missing_song and not result.is_valid(),
		"details": result.to_dict(),
	}
