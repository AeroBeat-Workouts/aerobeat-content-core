extends RefCounted

const Chart = preload("res://addons/aerobeat-content-core/data_types/chart.gd")
const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func _codes_from(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var legacy_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/invalid_boxing_legacy_chart_vocab")
	var legacy_fixture_result := validator.validate_fixture_package(legacy_fixture_path)
	var legacy_fixture_codes: Array[String] = []
	for issue in legacy_fixture_result.issues:
		legacy_fixture_codes.append(String(issue.get("code", "")))
	legacy_fixture_codes.sort()
	var boxing_end_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/invalid_boxing_end_field")
	var boxing_end_fixture_result := validator.validate_fixture_package(boxing_end_fixture_path)
	var boxing_end_fixture_codes: Array[String] = []
	for issue in boxing_end_fixture_result.issues:
		boxing_end_fixture_codes.append(String(issue.get("code", "")))
	boxing_end_fixture_codes.sort()
	var valid_boxing_issues := Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "straight_left",
			},
			{
				"start": 3.0,
				"type": "guard",
			}
		]
	})
	var legacy_boxing_codes := _codes_from(Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "punch_left",
			}
		]
	}))
	var stale_boxing_codes := _codes_from(Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "orthodox",
			}
		]
	}))
	var boxing_portal_codes := _codes_from(Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "hook_left",
				"portal": 9,
			}
		]
	}))
	var boxing_end_codes := _codes_from(Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "straight_left",
				"end": 2.0,
			}
		]
	}))
	var valid_flow_issues := Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"end": 1.5,
				"type": "burst",
				"hand": "left",
				"placement": 4,
				"direction": 6,
				"tailPlacement": 7,
				"checkpointCount": 3,
				"spacingBias": 0.25,
			}
		]
	})
	var invalid_flow_codes := _codes_from(Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"end": 1.5,
				"type": "burst",
				"hand": "left",
				"direction": 6,
				"tailPlacement": 7,
				"checkpointCount": 3,
			}
		]
	}))
	var stale_flow_codes := _codes_from(Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "swing_left",
			}
		]
	}))
	var flow_portal_codes := _codes_from(Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "note",
				"portal": 1,
			}
		]
	}))
	var passed := (
		not legacy_fixture_result.is_valid()
		and legacy_fixture_codes == ["invalid_boxing_type", "invalid_boxing_type", "invalid_boxing_type"]
		and not boxing_end_fixture_result.is_valid()
		and boxing_end_fixture_codes == ["invalid_boxing_end"]
		and valid_boxing_issues.is_empty()
		and legacy_boxing_codes == ["invalid_boxing_type"]
		and stale_boxing_codes == ["invalid_boxing_type"]
		and boxing_portal_codes == ["invalid_boxing_portal"]
		and boxing_end_codes == ["invalid_boxing_end"]
		and valid_flow_issues.is_empty()
		and invalid_flow_codes == ["flow_burst_missing_placement"]
		and stale_flow_codes == ["invalid_flow_type"]
		and flow_portal_codes == ["invalid_flow_portal", "invalid_flow_type"]
	)
	return {
		"name": "chart_event_contract",
		"passed": passed,
		"details": {
			"legacyFixtureIssues": legacy_fixture_result.to_dict(),
			"boxingEndFixtureIssues": boxing_end_fixture_result.to_dict(),
			"validBoxingIssues": valid_boxing_issues,
			"legacyBoxingCodes": legacy_boxing_codes,
			"staleBoxingCodes": stale_boxing_codes,
			"boxingPortalCodes": boxing_portal_codes,
			"boxingEndCodes": boxing_end_codes,
			"validFlowIssues": valid_flow_issues,
			"invalidFlowIssues": invalid_flow_codes,
			"staleFlowCodes": stale_flow_codes,
			"flowPortalCodes": flow_portal_codes,
		},
	}
