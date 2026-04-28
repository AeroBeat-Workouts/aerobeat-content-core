extends RefCounted

const Song = preload("res://../data_types/song.gd")

static func run() -> Dictionary:
	var missing_fields := Song.validate_shape({
		"schema": "aerobeat.content.song.v1",
		"songId": "song_demo",
		"songName": "Demo Song",
		"durationSec": 180,
		"audio": {},
	})
	var valid_timing_issues := Song.validate_timing_shape({
		"timing": {
			"anchorMs": 0,
			"tempoSegments": [
				{"startBeat": 0, "bpm": 128}
			],
			"stopSegments": [],
			"timeSignatureSegments": [
				{"startBeat": 0, "numerator": 4, "denominator": 4}
			],
		}
	})
	var invalid_timing_codes := _sorted_codes(Song.validate_timing_shape({
		"timing": {
			"anchorMs": 0,
			"bpm": 128,
			"tempoSegments": [
				{"startBeat": 0},
			],
			"stopSegments": [],
			"timeSignatureSegments": [
				{"startBeat": 0, "numerator": 4},
			],
		}
	}))
	var passed := (
		missing_fields == ["timing"]
		and valid_timing_issues.is_empty()
		and invalid_timing_codes == [
			"song_tempo_segment_missing_field",
			"song_time_signature_segment_missing_field",
			"song_timing_bpm_shortcut_forbidden",
		]
	)
	return {
		"name": "song_timing_contract",
		"passed": passed,
		"details": {
			"missingFields": missing_fields,
			"validTimingIssues": valid_timing_issues,
			"invalidTimingCodes": invalid_timing_codes,
		},
	}

static func _sorted_codes(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
