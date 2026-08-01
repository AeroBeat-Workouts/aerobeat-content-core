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
		"mode": "boxing",
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
		"mode": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "punch_left",
			}
		]
	}))
	var stale_boxing_codes := _codes_from(Chart.validate_contract({
		"mode": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "orthodox",
			}
		]
	}))
	var boxing_portal_codes := _codes_from(Chart.validate_contract({
		"mode": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "hook_left",
				"portal": 9,
			}
		]
	}))
	var boxing_end_codes := _codes_from(Chart.validate_contract({
		"mode": "boxing",
		"beats": [
			{
				"start": 1.0,
				"type": "straight_left",
				"end": 2.0,
			}
		]
	}))
	var valid_flow_issues := Chart.validate_contract({
		"mode": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "note",
				"hand": "left",
				"placement": 4,
				"requiresDirection": true,
				"direction": 6,
				"angleOffset": 15.0,
			},
			{
				"start": 1.25,
				"end": 1.75,
				"type": "burst",
				"hand": "left",
				"placement": 4,
				"direction": 6,
				"tailPlacement": 7,
				"checkpointCount": 3,
				"spacingBias": 0.25,
			},
			{
				"start": 2.0,
				"type": "bomb",
				"placement": 5,
			},
			{
				"start": 2.5,
				"end": 4.0,
				"type": "obstacle",
				"cells": [4, 5, 8, 9],
			},
			{
				"start": 5.0,
				"end": 5.75,
				"type": "arc",
				"hand": "right",
				"startPlacement": 6,
				"endPlacement": 10,
				"startDirection": 3,
				"endDirection": 1,
				"headCurveMultiplier": 1.25,
				"tailCurveMultiplier": 0.8,
				"midAnchorMode": 2,
				"startNoteRef": "note-head-01",
				"endNoteRef": "note-tail-01",
			}
		]
	})
	var directionless_note_issues := Chart.validate_contract({
		"mode": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "note",
				"hand": "right",
				"placement": 6,
				"requiresDirection": false,
			}
		]
	})
	var invalid_flow_codes := _codes_from(Chart.validate_contract({
		"mode": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "note",
				"hand": "left",
				"placement": 4,
				"requiresDirection": false,
				"direction": 6,
				"angleOffset": "bad",
			},
			{
				"start": 1.5,
				"end": 2.0,
				"type": "burst",
				"hand": "left",
				"direction": 6,
				"tailPlacement": 7,
				"checkpointCount": 3,
			},
			{
				"start": 2.5,
				"type": "bomb",
				"placement": "bad",
				"end": 2.6,
			},
			{
				"start": 3.0,
				"type": "obstacle",
				"cells": [4, "bad"],
			},
			{
				"start": 4.0,
				"end": 4.5,
				"type": "arc",
				"hand": "right",
				"startPlacement": 5,
				"endPlacement": 8,
				"startDirection": 2,
				"endDirection": 3,
				"headCurveMultiplier": 1.0,
				"tailCurveMultiplier": 0.5,
				"midAnchorMode": "bad",
				"startNoteRef": 4,
			}
		]
	}))
	var stale_flow_codes := _codes_from(Chart.validate_contract({
		"mode": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "swing_left",
			}
		]
	}))
	var flow_portal_codes := _codes_from(Chart.validate_contract({
		"mode": "flow",
		"beats": [
			{
				"start": 1.0,
				"type": "note",
				"portal": 1,
			}
		]
	}))
	var passed: bool = (
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
		and directionless_note_issues.is_empty()
		and invalid_flow_codes == [
			"flow_arc_invalid_mid_anchor_mode",
			"flow_arc_invalid_start_note_ref",
			"flow_bomb_invalid_placement",
			"flow_bomb_unexpected_end",
			"flow_burst_missing_placement",
			"flow_note_invalid_angle_offset",
			"flow_note_unexpected_direction",
			"flow_obstacle_invalid_cell",
			"flow_obstacle_missing_end",
		]
		and stale_flow_codes == ["invalid_flow_type"]
		and flow_portal_codes == [
			"flow_note_missing_hand",
			"flow_note_missing_placement",
			"flow_note_missing_requires_direction",
			"invalid_flow_portal",
		]
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
			"directionlessNoteIssues": directionless_note_issues,
			"invalidFlowIssues": invalid_flow_codes,
			"staleFlowCodes": stale_flow_codes,
			"flowPortalCodes": flow_portal_codes,
		},
	}
