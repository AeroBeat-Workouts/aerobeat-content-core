extends RefCounted

const ContentPackageValidatorScript = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")
const SimpleYamlParserScript = preload("res://addons/aerobeat-content-core/validators/simple_yaml_parser.gd")

const CASES := [
	{"id": "29be2", "group": "Sonic Songs - Heavy Metal / Rock", "difficulty_role": "Very fast upper-end speed references", "mode": "flow", "difficulty": "ExpertPlus"},
	{"id": "349f2", "group": "Sonic Songs - Heavy Metal / Rock", "difficulty_role": "Very fast upper-end speed references", "mode": "flow", "difficulty": "ExpertPlus"},
	{"id": "2b4e6", "group": "Sonic Songs - Heavy Metal / Rock", "difficulty_role": "Very fast upper-end speed references", "mode": "flow", "difficulty": "ExpertPlus"},
	{"id": "304ea", "group": "Sonic Songs - Heavy Metal / Rock", "difficulty_role": "Very fast upper-end speed references", "mode": "flow", "difficulty": "ExpertPlus"},
	{"id": "48727", "group": "Kpop Demon Hunters - K-Pop", "difficulty_role": "Simpler reference songs", "mode": "flow", "difficulty": "Normal"},
	{"id": "48088", "group": "Kpop Demon Hunters - K-Pop", "difficulty_role": "Simpler reference songs", "mode": "flow", "difficulty": "Normal"},
	{"id": "48792", "group": "Kpop Demon Hunters - K-Pop", "difficulty_role": "Simpler reference songs", "mode": "flow", "difficulty": "Normal"},
	{"id": "47fb6", "group": "Kpop Demon Hunters - K-Pop", "difficulty_role": "Simpler reference songs", "mode": "flow", "difficulty": "Normal"},
	{"id": "3d44b", "group": "Game Grumps / NSP - Meme", "difficulty_role": "Simpler/meme reference songs", "mode": "boxing", "difficulty": "Normal"},
	{"id": "472d3", "group": "Game Grumps / NSP - Meme", "difficulty_role": "Simpler/meme reference songs", "mode": "boxing", "difficulty": "Normal"},
	{"id": "226e", "group": "Linkin Park - Rock Alternative", "difficulty_role": "Mid-level challenge references for Derrick's Expert baseline", "mode": "boxing", "difficulty": "Expert"},
	{"id": "2f3d7", "group": "Linkin Park - Rock Alternative", "difficulty_role": "Mid-level challenge references for Derrick's Expert baseline", "mode": "boxing", "difficulty": "Expert"},
	{"id": "4858", "group": "Linkin Park - Rock Alternative", "difficulty_role": "Mid-level challenge references for Derrick's Expert baseline", "mode": "boxing", "difficulty": "Expert"},
	{"id": "19e5e", "group": "Linkin Park - Rock Alternative", "difficulty_role": "Mid-level challenge references for Derrick's Expert baseline", "mode": "boxing", "difficulty": "Expert"},
]

static func run() -> Dictionary:
	var validator := ContentPackageValidatorScript.new()
	var parser := SimpleYamlParserScript.new()
	var fixture_root := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/beatsaver_regression_pool")
	var invalid_cases: Array = []
	var seen_ids: Dictionary = {}

	for case in CASES:
		var beatsaver_id := str(case.get("id", ""))
		var package_dir := fixture_root.path_join(beatsaver_id)
		var result := validator.validate_song_package_yaml_package(package_dir)
		var root := Dictionary(parser.parse_file(package_dir.path_join("song.package.yaml")))
		var charts := Array(root.get("charts", []))
		var descriptor := Dictionary(charts[0] if not charts.is_empty() else {})
		var chart_path := package_dir.path_join(str(descriptor.get("path", "")))
		var chart := Dictionary(parser.parse_file(chart_path))
		var source := Dictionary(root.get("source", {}))
		var regression := Dictionary(root.get("regression", {}))
		var chart_source := Dictionary(chart.get("source", {}))
		var chart_regression := Dictionary(chart.get("regression", {}))
		var case_valid: bool = (
			result.is_valid()
			and source.get("provider", "") == "beatsaver"
			and str(source.get("beatsaverId", "")) == beatsaver_id
			and str(chart_source.get("beatsaverId", "")) == beatsaver_id
			and regression.get("group", "") == case.get("group", "")
			and regression.get("difficultyRole", "") == case.get("difficulty_role", "")
			and regression.get("fixtureScope", "") == "contract_valid_metadata_chart_slice"
			and chart_regression.get("group", "") == case.get("group", "")
			and chart_regression.get("difficultyRole", "") == case.get("difficulty_role", "")
			and descriptor.get("mode", "") == case.get("mode", "")
			and descriptor.get("difficulty", "") == case.get("difficulty", "")
			and chart.get("mode", "") == case.get("mode", "")
			and chart.get("difficulty", "") == case.get("difficulty", "")
			and not Array(chart.get("beats", [])).is_empty()
			and not seen_ids.has(beatsaver_id)
		)
		seen_ids[beatsaver_id] = true
		if not case_valid:
			invalid_cases.append({
				"beatsaverId": beatsaver_id,
				"validation": result.to_dict(),
				"rootSource": source,
				"rootRegression": regression,
				"chartSource": chart_source,
				"chartRegression": chart_regression,
				"descriptor": descriptor,
				"chart": chart,
			})

	var passed := invalid_cases.is_empty() and seen_ids.size() == CASES.size()
	return {
		"name": "beatsaver_regression_fixtures",
		"passed": passed,
		"details": {
			"caseCount": CASES.size(),
			"invalidCases": invalid_cases,
			"fixtureLimitation": "Synthetic contract-valid metadata/package/chart slices; full BeatSaver maps, audio, and cover assets are not included.",
		},
	}
