extends RefCounted

const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://../fixtures/package_minimal_boxing")
	var missing_set_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_missing_set_ref")
	var duplicate_fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_duplicate_set_order_ids")
	var valid_result := validator.validate_fixture_package(valid_fixture_path)
	var missing_set_result := validator.validate_fixture_package(missing_set_fixture_path)
	var duplicate_result := validator.validate_fixture_package(duplicate_fixture_path)
	var missing_set_codes := _sorted_codes(missing_set_result.issues)
	var duplicate_codes := _sorted_codes(duplicate_result.issues)
	var passed := (
		valid_result.is_valid()
		and missing_set_codes == ["missing_set_ref"]
		and duplicate_codes == ["duplicate_set_order_id"]
	)
	return {
		"name": "workout_resolution_validation",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"missingSet": missing_set_result.to_dict(),
			"duplicateSetOrder": duplicate_result.to_dict(),
		},
	}

static func _sorted_codes(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
