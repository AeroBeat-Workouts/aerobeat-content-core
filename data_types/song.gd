class_name Song
extends RefCounted

const REQUIRED_FIELDS := ["schema", "songId", "songName", "durationSec", "audio", "timing"]
const TIMING_REQUIRED_FIELDS := ["anchorMs", "tempoSegments", "stopSegments", "timeSignatureSegments"]
const AUDIO_OPTIONAL_STRING_FIELDS := [
	"resourcePath",
	"filePath",
	"previewResourcePath",
	"previewFilePath",
	"previewUrl",
]
const AUDIO_OPTIONAL_NUMBER_FIELDS := [
	"previewStartTime",
	"previewDuration",
]
const VALID_PREVIEW_MODES := [
	"song_file_clip",
	"preview_file",
	"preview_url",
]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	for field in REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_audio_shape(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not data.has("audio"):
		return issues
	var audio_value: Variant = data.get("audio")
	if not (audio_value is Dictionary):
		issues.append({
			"code": "song_audio_invalid_type",
			"message": "Song audio must be a dictionary.",
			"field": "audio",
		})
		return issues
	var audio: Dictionary = audio_value
	for field in AUDIO_OPTIONAL_STRING_FIELDS:
		if audio.has(field) and not _is_non_empty_string(audio.get(field)):
			issues.append({
				"code": "song_audio_field_invalid_type",
				"message": "Song audio field '%s' must be a non-empty string when present." % field,
				"field": "audio.%s" % field,
			})
	for field in AUDIO_OPTIONAL_NUMBER_FIELDS:
		if audio.has(field) and not _is_number(audio.get(field)):
			issues.append({
				"code": "song_audio_field_invalid_type",
				"message": "Song audio field '%s' must be a number when present." % field,
				"field": "audio.%s" % field,
			})
	issues.append_array(_validate_preview_timing_ranges(audio))
	if audio.has("previewMode"):
		var preview_mode := String(audio.get("previewMode", ""))
		if preview_mode.is_empty() or not (preview_mode in VALID_PREVIEW_MODES):
			issues.append({
				"code": "song_audio_invalid_preview_mode",
				"message": "Song audio previewMode must be one of song_file_clip/preview_file/preview_url when present.",
				"field": "audio.previewMode",
			})
	return issues

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

static func _validate_preview_timing_ranges(audio: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if audio.has("previewStartTime"):
		var preview_start_time := audio.get("previewStartTime")
		if _is_number(preview_start_time) and float(preview_start_time) < 0.0:
			issues.append({
				"code": "song_audio_preview_start_time_invalid_value",
				"message": "Song audio previewStartTime must be greater than or equal to 0 when present.",
				"field": "audio.previewStartTime",
			})
	if audio.has("previewDuration"):
		var preview_duration := audio.get("previewDuration")
		if _is_number(preview_duration) and float(preview_duration) <= 0.0:
			issues.append({
				"code": "song_audio_preview_duration_invalid_value",
				"message": "Song audio previewDuration must be greater than 0 when present.",
				"field": "audio.previewDuration",
			})
	return issues

static func _is_integer_number(value: Variant) -> bool:
	return value is int or (value is float and floor(value) == value)

static func _is_number(value: Variant) -> bool:
	return value is int or value is float

static func _is_non_empty_string(value: Variant) -> bool:
	return value is String and not String(value).strip_edges().is_empty()
