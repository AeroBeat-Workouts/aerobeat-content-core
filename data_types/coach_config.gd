class_name CoachConfig
extends RefCounted

const ENABLED_REQUIRED_FIELDS := ["schema", "coachConfigId", "coachConfigName", "enabled", "featuredCoaches", "warmupVideo", "cooldownVideo", "overlayAudio"]

static func validate_shape(data: Dictionary) -> Array[String]:
	var missing: Array[String] = []
	if not data.has("enabled"):
		return ["enabled"]
	if not bool(data.get("enabled", false)):
		return missing
	for field in ENABLED_REQUIRED_FIELDS:
		if not data.has(field):
			missing.append(field)
	return missing

static func validate_contract(data: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not data.has("enabled") or not (data.get("enabled") is bool):
		issues.append({
			"code": "coach_config_enabled_missing",
			"message": "Coach config must declare boolean enabled.",
			"field": "enabled",
		})
		return issues
	if not bool(data.get("enabled", false)):
		if data.keys().size() != 1:
			issues.append({
				"code": "coach_config_disabled_not_minimal",
				"message": "Disabled coach config must be minimal and contain only enabled: false.",
			})
		return issues
	var featured_coaches: Array = data.get("featuredCoaches", []) if data.get("featuredCoaches") is Array else []
	if not (data.get("featuredCoaches") is Array):
		issues.append({
			"code": "featured_coaches_invalid_type",
			"message": "Coach config featuredCoaches must be an array.",
			"field": "featuredCoaches",
		})
	var coach_ids: Dictionary = {}
	for index in range(featured_coaches.size()):
		var coach_value: Variant = featured_coaches[index]
		if not (coach_value is Dictionary):
			issues.append({
				"code": "featured_coach_invalid_type",
				"message": "featuredCoaches entries must be dictionaries.",
				"field": "featuredCoaches[%d]" % index,
				"index": index,
			})
			continue
		var coach: Dictionary = coach_value
		for field in ["coachId", "coachName"]:
			if not coach.has(field):
				issues.append({
					"code": "featured_coach_missing_field",
					"message": "Featured coach is missing required field '%s'." % field,
					"field": "featuredCoaches[%d].%s" % [index, field],
					"index": index,
				})
		var coach_id := String(coach.get("coachId", ""))
		if not coach_id.is_empty():
			if coach_ids.has(coach_id):
				issues.append({
					"code": "duplicate_id",
					"message": "Duplicate featured coach id '%s'." % coach_id,
					"field": "featuredCoaches[%d].coachId" % index,
					"index": index,
				})
			else:
				coach_ids[coach_id] = true
	var overlay_audio: Array = data.get("overlayAudio", []) if data.get("overlayAudio") is Array else []
	if not (data.get("overlayAudio") is Array):
		issues.append({
			"code": "overlay_audio_invalid_type",
			"message": "Coach config overlayAudio must be an array.",
			"field": "overlayAudio",
		})
	var overlay_ids: Dictionary = {}
	for index in range(overlay_audio.size()):
		var overlay_value: Variant = overlay_audio[index]
		if not (overlay_value is Dictionary):
			issues.append({
				"code": "overlay_audio_entry_invalid_type",
				"message": "overlayAudio entries must be dictionaries.",
				"field": "overlayAudio[%d]" % index,
				"index": index,
			})
			continue
		var overlay: Dictionary = overlay_value
		for field in ["overlayId", "coachId", "mediaId", "path"]:
			if not overlay.has(field):
				issues.append({
					"code": "overlay_audio_missing_field",
					"message": "Coach overlay is missing required field '%s'." % field,
					"field": "overlayAudio[%d].%s" % [index, field],
					"index": index,
				})
		var overlay_id := String(overlay.get("overlayId", ""))
		if not overlay_id.is_empty():
			if overlay_ids.has(overlay_id):
				issues.append({
					"code": "duplicate_id",
					"message": "Duplicate coach overlay id '%s'." % overlay_id,
					"field": "overlayAudio[%d].overlayId" % index,
					"index": index,
				})
			else:
				overlay_ids[overlay_id] = true
		var overlay_coach_id := String(overlay.get("coachId", ""))
		if not overlay_coach_id.is_empty() and not coach_ids.has(overlay_coach_id):
			issues.append({
				"code": "missing_coach_ref",
				"message": "Coach overlay references coachId that is not present in featuredCoaches.",
				"field": "overlayAudio[%d].coachId" % index,
				"index": index,
			})
	return issues

static func overlay_audio_index(data: Dictionary) -> Dictionary:
	var index: Dictionary = {}
	var overlay_audio: Variant = data.get("overlayAudio", [])
	if not (overlay_audio is Array):
		return index
	for overlay_value in overlay_audio:
		if not (overlay_value is Dictionary):
			continue
		var overlay: Dictionary = overlay_value
		var overlay_id := String(overlay.get("overlayId", ""))
		if not overlay_id.is_empty():
			index[overlay_id] = overlay
	return index
