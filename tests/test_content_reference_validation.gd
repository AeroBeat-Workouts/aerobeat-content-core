extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_missing_song_ref")
	var result := validator.validate_fixture_package(fixture_path)
	var issue_codes: Array[String] = []
	for issue in result.issues:
		issue_codes.append(String(issue.get("code", "")))
	issue_codes.sort()
	var passed := (
		not result.is_valid()
		and issue_codes == ["missing_song_ref", "missing_song_ref"]
	)
	return {
		"name": "content_reference_validation",
		"passed": passed,
		"details": result.to_dict(),
	}
