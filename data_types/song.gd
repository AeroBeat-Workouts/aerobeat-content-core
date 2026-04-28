class_name Song
extends RefCounted

const REQUIRED_FIELDS := ["schema", "songId", "songName", "durationSec", "audio", "timing"]
const TIMING_REQUIRED_FIELDS := ["anchorMs", "tempoSegments", "stopSegments", "timeSignatureSegments"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_timing_shape(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not data.has("timing"):
		return issues
	var timing_value: Variant = data.get("timing")
	if not (timing_value is Dictionary):
		issues.append({
			"code": "song_timing_invalid_type",
			"message": "Song timing must be a dictionary.",
			"field": "timing",
		})
		return issues
	var timing: Dictionary = timing_value
	if timing.has("bpm"):
		issues.append({
			"code": "song_timing_bpm_shortcut_forbidden",
			"message": "Song timing must use tempoSegments and must not include a timing.bpm shortcut.",
			"field": "timing.bpm",
		})
	for field in TIMING_REQUIRED_FIELDS:
		if not timing.has(field):
			issues.append({
				"code": "song_timing_missing_field",
				"message": "Song timing is missing required field '%s'." % field,
				"field": "timing.%s" % field,
			})
	if timing.has("anchorMs") and not _is_integer_number(timing.get("anchorMs")):
		issues.append({
			"code": "song_timing_anchor_invalid_type",
			"message": "Song timing anchorMs must be an integer millisecond value.",
			"field": "timing.anchorMs",
		})
	issues.append_array(_validate_tempo_segments(timing))
	issues.append_array(_validate_stop_segments(timing))
	issues.append_array(_validate_time_signature_segments(timing))
	return issues

static func _validate_tempo_segments(timing: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not timing.has("tempoSegments"):
		return issues
	var segments_value: Variant = timing.get("tempoSegments")
	if not (segments_value is Array):
		issues.append({
			"code": "song_tempo_segments_invalid_type",
			"message": "Song timing tempoSegments must be an array.",
			"field": "timing.tempoSegments",
		})
		return issues
	for index in range(segments_value.size()):
		var segment_value: Variant = segments_value[index]
		if not (segment_value is Dictionary):
			issues.append({
				"code": "song_tempo_segment_invalid_type",
				"message": "Song tempo segment entries must be dictionaries.",
				"field": "timing.tempoSegments[%d]" % index,
				"index": index,
			})
			continue
		var segment: Dictionary = segment_value
		for field in ["startBeat", "bpm"]:
			if not segment.has(field):
				issues.append({
					"code": "song_tempo_segment_missing_field",
					"message": "Song tempo segment is missing required field '%s'." % field,
					"field": "timing.tempoSegments[%d].%s" % [index, field],
					"index": index,
				})
	return issues

static func _validate_stop_segments(timing: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not timing.has("stopSegments"):
		return issues
	var segments_value: Variant = timing.get("stopSegments")
	if not (segments_value is Array):
		issues.append({
			"code": "song_stop_segments_invalid_type",
			"message": "Song timing stopSegments must be an array.",
			"field": "timing.stopSegments",
		})
		return issues
	for index in range(segments_value.size()):
		var segment_value: Variant = segments_value[index]
		if not (segment_value is Dictionary):
			issues.append({
				"code": "song_stop_segment_invalid_type",
				"message": "Song stop segment entries must be dictionaries.",
				"field": "timing.stopSegments[%d]" % index,
				"index": index,
			})
			continue
		var segment: Dictionary = segment_value
		for field in ["startBeat", "durationMs"]:
			if not segment.has(field):
				issues.append({
					"code": "song_stop_segment_missing_field",
					"message": "Song stop segment is missing required field '%s'." % field,
					"field": "timing.stopSegments[%d].%s" % [index, field],
					"index": index,
				})
	return issues

static func _validate_time_signature_segments(timing: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not timing.has("timeSignatureSegments"):
		return issues
	var segments_value: Variant = timing.get("timeSignatureSegments")
	if not (segments_value is Array):
		issues.append({
			"code": "song_time_signature_segments_invalid_type",
			"message": "Song timing timeSignatureSegments must be an array.",
			"field": "timing.timeSignatureSegments",
		})
		return issues
	for index in range(segments_value.size()):
		var segment_value: Variant = segments_value[index]
		if not (segment_value is Dictionary):
			issues.append({
				"code": "song_time_signature_segment_invalid_type",
				"message": "Song time-signature segment entries must be dictionaries.",
				"field": "timing.timeSignatureSegments[%d]" % index,
				"index": index,
			})
			continue
		var segment: Dictionary = segment_value
		for field in ["startBeat", "numerator", "denominator"]:
			if not segment.has(field):
				issues.append({
					"code": "song_time_signature_segment_missing_field",
					"message": "Song time-signature segment is missing required field '%s'." % field,
					"field": "timing.timeSignatureSegments[%d].%s" % [index, field],
					"index": index,
				})
	return issues

static func _is_integer_number(value: Variant) -> bool:
	return value is int or (value is float and floor(value) == value)
