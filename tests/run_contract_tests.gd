extends SceneTree

const TEST_SCRIPTS := [
	preload("res://addons/aerobeat-content-core/tests/test_content_manifest_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_content_reference_validation.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_content_mode_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_environment_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_chart_event_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_legacy_package_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_song_timing_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_song_timing_validation.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_song_preview_audio_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_song_package_yaml_contract.gd"),
	preload("res://addons/aerobeat-content-core/tests/test_beatsaver_regression_fixtures.gd"),
]

func _initialize() -> void:
	var results: Array[Dictionary] = []
	var has_failures := false
	for test_script in TEST_SCRIPTS:
		var test_result: Dictionary = test_script.run()
		results.append(test_result)
		if not bool(test_result.get("passed", false)):
			has_failures = true
	var summary: Dictionary = {
		"passed": not has_failures,
		"results": results,
	}
	print(JSON.stringify(summary, "  "))
	quit(1 if has_failures else 0)
