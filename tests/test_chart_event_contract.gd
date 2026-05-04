extends RefCounted

const Chart = preload("res://../data_types/chart.gd")
const ContentPackageValidator = preload("res://../validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var fixture_path := ProjectSettings.globalize_path("res://../fixtures/invalid_boxing_legacy_chart_vocab")
	var fixture_result := validator.validate_fixture_package(fixture_path)
	var fixture_codes: Array[String] = []
	for issue in fixture_result.issues:
		fixture_codes.append(String(issue.get("code", "")))
	fixture_codes.sort()
	var valid_boxing_issues := Chart.validate_contract({
		"feature": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "orthodox",
				"end": 2.0,
			},
			{
				"start": 3.0,
				"type": "southpaw",
			}
		]
	})
	var valid_flow_issues := Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "arc",
				"placement": 4,
				"direction": 6,
			}
		]
	})
	var invalid_flow_issues := Chart.validate_contract({
		"feature": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "arc",
				"direction": 6,
			}
		]
	})
	var invalid_flow_codes: Array[String] = []
	for issue in invalid_flow_issues:
		invalid_flow_codes.append(String(issue.get("code", "")))
	invalid_flow_codes.sort()
	var passed := (
		not fixture_result.is_valid()
		and fixture_codes == ["invalid_boxing_type", "invalid_boxing_type"]
		and valid_boxing_issues.is_empty()
		and valid_flow_issues.is_empty()
		and invalid_flow_codes == ["flow_beat_missing_placement"]
	)
	return {
		"name": "chart_event_contract",
		"passed": passed,
		"details": {
			"fixtureIssues": fixture_result.to_dict(),
			"validBoxingIssues": valid_boxing_issues,
			"validFlowIssues": valid_flow_issues,
			"invalidFlowIssues": invalid_flow_issues,
		},
	}
