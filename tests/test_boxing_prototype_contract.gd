extends RefCounted

const Chart = preload("res://addons/aerobeat-content-core/data_types/chart.gd")
const Contract = preload("res://addons/aerobeat-content-core/globals/boxing_prototype_contract.gd")
const Schema = preload("res://addons/aerobeat-content-core/globals/aero_content_schema.gd")

static func _prototype(ruleset_id: String = "boxing_spatial_grid_v1") -> Dictionary:
	return {
		"contractId": Contract.CONTRACT_ID,
		"recipeId": "row_family_balanced_height_v1",
		"recipeVersion": "1.0.0",
		"rulesetId": ruleset_id,
		"rulesetVersion": "1.0.0",
		"sourceHash": "sha256:" + "a".repeat(64),
		"recipeHash": "sha256:" + "b".repeat(64),
		"rulesetHash": "sha256:" + "c".repeat(64),
		"contentHash": "sha256:" + "d".repeat(64),
		"modifiers": ["crossed_guard"],
	}

static func _codes(issues: Array) -> Array[String]:
	var result: Array[String] = []
	for issue in issues:
		result.append(String(Dictionary(issue).get("code", "")))
	result.sort()
	return result

static func run() -> Dictionary:
	var valid := {
		"mode": "boxing",
		"prototype": _prototype(),
		"presentationSuggestion": {"themeId": "aero-default"},
		"beats": [
			{
				"start": 1.0,
				"type": "straight_left",
				"eventId": "event-punch",
				"sourceEventIds": ["source-1"],
				"timingWindowMs": 180,
				"evidenceFreshnessMs": 150,
				"spatialTarget": {"targetCell": 5, "acceptedSubcells": [18, 19, 20, 26, 27, 28], "entryDirection": "up", "qualificationMs": 100},
			},
			{
				"start": 2.0,
				"type": "guard",
				"eventId": "event-guard",
				"sourceEventIds": ["source-2", "source-3"],
				"timingWindowMs": 180,
				"evidenceFreshnessMs": 150,
				"modifier": "crossed_guard",
				"guardTarget": {"leftCell": 6, "rightCell": 5, "crossed": true},
				"checkpoint": {"kind": "instantaneous", "freshnessMs": 150, "timingWindowMs": 180},
			},
			{
				"start": 3.0,
				"type": "squat",
				"eventId": "event-obstacle",
				"sourceEventIds": ["source-4"],
				"checkpoint": {"kind": "instantaneous", "freshnessMs": 150, "timingWindowMs": 180},
				"blockedCells": [0, 1, 2, 3],
			},
		],
	}
	var invalid := valid.duplicate(true)
	invalid["prototype"]["recipeId"] = "unknown"
	invalid["prototype"]["modifiers"] = ["unknown"]
	invalid["beats"][0].erase("eventId")
	invalid["beats"][0]["spatialTarget"]["targetCell"] = 12
	invalid["beats"][1]["guardTarget"] = {"leftCell": 3, "rightCell": 4, "crossed": false}
	invalid["beats"][2]["checkpoint"]["freshnessMs"] = 1000
	var valid_issues := Chart.validate_contract(valid)
	var invalid_codes := _codes(Chart.validate_contract(invalid))
	var malformed := valid.duplicate(true)
	malformed["prototype"]["sourceHash"] = "sha256:bad"
	malformed["prototype"]["modifiers"] = ["crossed_guard", "crossed_guard"]
	malformed["beats"][0]["sourceEventIds"] = [null]
	malformed["beats"][0]["timingWindowMs"] = "180"
	malformed["beats"][0]["spatialTarget"]["targetCell"] = "5"
	malformed["beats"][0]["spatialTarget"]["acceptedSubcells"] = [18, 18]
	malformed["beats"][1]["guardTarget"] = {"leftCell": 12, "rightCell": 13, "crossed": "yes"}
	malformed["beats"][2]["blockedCells"] = [12, 12]
	malformed["beats"][2]["checkpoint"]["timingWindowMs"] = 999
	var malformed_codes := _codes(Chart.validate_contract(malformed))
	var expected := [
		"boxing_checkpoint_invalid_freshness",
		"boxing_event_missing_id",
		"boxing_event_modifier_not_in_identity",
		"boxing_guard_invalid_pair",
		"boxing_prototype_invalid_modifier",
		"boxing_prototype_invalid_recipe",
		"boxing_punch_invalid_target_cell",
	]
	var malformed_expected := [
		"boxing_checkpoint_invalid_blocked_cells",
		"boxing_checkpoint_invalid_timing_window",
		"boxing_event_invalid_lineage",
		"boxing_event_invalid_timing_window",
		"boxing_guard_invalid_pair",
		"boxing_prototype_duplicate_modifier",
		"boxing_prototype_invalid_hash",
		"boxing_punch_duplicate_subcell",
		"boxing_punch_invalid_target_cell",
	]
	var malformed_covered := true
	for code in malformed_expected:
		if not malformed_codes.has(code):
			malformed_covered = false
	return {
		"name": "boxing_prototype_contract",
		"passed": valid_issues.is_empty() and invalid_codes == expected and malformed_covered and Schema.is_known_schema(Contract.CONTRACT_ID) and not Schema.is_known_record_schema(Contract.CONTRACT_ID),
		"details": {"validIssues": valid_issues, "invalidCodes": invalid_codes, "malformedCodes": malformed_codes},
	}
