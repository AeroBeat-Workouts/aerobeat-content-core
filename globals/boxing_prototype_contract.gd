class_name BoxingPrototypeContract
extends RefCounted

const CONTRACT_ID := "aerobeat.boxing.prototype.v1"
const RECIPE_IDS := ["row_family_balanced_height_v1", "cut_family_source_height_v1"]
const RULESET_IDS := ["boxing_semantic_track_v1", "boxing_spatial_grid_v1"]
const MODIFIER_IDS := ["no_squats", "no_weaves", "any_punch", "crossed_guard", "cross_body"]
const PUNCH_TYPES := ["straight_left", "straight_right", "hook_left", "hook_right", "uppercut_left", "uppercut_right"]
const CHECKPOINT_TYPES := ["guard", "squat", "weave_left", "weave_right"]
const CARDINAL_DIRECTIONS := ["up", "down", "left", "right"]
const PROTOTYPE_TIMING_WINDOW_MS := 180
const FRESH_EVIDENCE_MS := 150
const STRAIGHT_QUALIFICATION_MS := 100
const PUNCH_MIN_SPACING_MS := 360

static func validate_chart_metadata(chart: Dictionary) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	if not chart.has("prototype"):
		return issues
	var value: Variant = chart.get("prototype")
	if not (value is Dictionary):
		return [_issue("boxing_prototype_invalid", "prototype", "Boxing prototype metadata must be a dictionary.")]
	var prototype: Dictionary = value
	if String(prototype.get("contractId", "")) != CONTRACT_ID:
		issues.append(_issue("boxing_prototype_invalid_contract", "prototype.contractId", "Boxing prototype contractId must be %s." % CONTRACT_ID))
	var recipe_id := String(prototype.get("recipeId", ""))
	if not recipe_id in RECIPE_IDS:
		issues.append(_issue("boxing_prototype_invalid_recipe", "prototype.recipeId", "Boxing prototype recipeId is not recognized."))
	var ruleset_id := String(prototype.get("rulesetId", ""))
	if not ruleset_id in RULESET_IDS:
		issues.append(_issue("boxing_prototype_invalid_ruleset", "prototype.rulesetId", "Boxing prototype rulesetId is not recognized."))
	for field in ["recipeVersion", "rulesetVersion"]:
		if not _non_empty_string(prototype.get(field)):
			issues.append(_issue("boxing_prototype_missing_identity", "prototype.%s" % field, "Boxing prototype %s must be a non-empty string." % field))
	for field in ["sourceHash", "recipeHash", "rulesetHash", "contentHash"]:
		if not _valid_sha256(prototype.get(field)):
			issues.append(_issue("boxing_prototype_invalid_hash", "prototype.%s" % field, "Boxing prototype %s must use sha256 plus 64 lowercase hexadecimal digits." % field))
	var modifiers: Variant = prototype.get("modifiers", [])
	if not (modifiers is Array):
		issues.append(_issue("boxing_prototype_invalid_modifiers", "prototype.modifiers", "Boxing prototype modifiers must be an array."))
	else:
		var seen_modifiers := {}
		for index in range(modifiers.size()):
			var modifier: Variant = modifiers[index]
			if not (modifier is String) or not String(modifier) in MODIFIER_IDS:
				issues.append(_issue("boxing_prototype_invalid_modifier", "prototype.modifiers[%d]" % index, "Boxing prototype modifier is not recognized."))
			elif seen_modifiers.has(String(modifier)):
				issues.append(_issue("boxing_prototype_duplicate_modifier", "prototype.modifiers[%d]" % index, "Boxing prototype modifiers must be unique."))
			else:
				seen_modifiers[String(modifier)] = true
		for beat_variant in Array(chart.get("beats", [])):
			if not (beat_variant is Dictionary):
				continue
			var beat_modifier: Variant = Dictionary(beat_variant).get("modifier")
			if beat_modifier != null and (not (beat_modifier is String) or not String(beat_modifier) in MODIFIER_IDS):
				issues.append(_issue("boxing_event_invalid_modifier", "beats.modifier", "Boxing event modifier is not recognized."))
			elif beat_modifier is String and not modifiers.has(String(beat_modifier)):
				issues.append(_issue("boxing_event_modifier_not_in_identity", "beats.modifier", "Boxing event modifier must be included in prototype.modifiers."))
	if chart.has("presentationSuggestion"):
		var suggestion: Variant = chart.get("presentationSuggestion")
		if not (suggestion is Dictionary):
			issues.append(_issue("presentation_suggestion_invalid", "presentationSuggestion", "Presentation suggestion must be a dictionary."))
		elif not _non_empty_string(Dictionary(suggestion).get("themeId")) and not _non_empty_string(Dictionary(suggestion).get("backgroundUrl")):
			issues.append(_issue("presentation_suggestion_empty", "presentationSuggestion", "Presentation suggestion must provide themeId or backgroundUrl."))
	return issues

static func validate_boxing_beat(beat: Dictionary, beat_type: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var prefix := "beats[%d]" % index
	if not _non_empty_string(beat.get("eventId")):
		issues.append(_issue("boxing_event_missing_id", "%s.eventId" % prefix, "Prototype Boxing events require a stable eventId.", index))
	var source_ids: Variant = beat.get("sourceEventIds", [])
	if not (source_ids is Array) or source_ids.is_empty():
		issues.append(_issue("boxing_event_missing_lineage", "%s.sourceEventIds" % prefix, "Prototype Boxing events require sourceEventIds.", index))
	else:
		var seen_source_ids := {}
		for source_index in range(source_ids.size()):
			var source_id: Variant = source_ids[source_index]
			if not _non_empty_string(source_id):
				issues.append(_issue("boxing_event_invalid_lineage", "%s.sourceEventIds[%d]" % [prefix, source_index], "Source event IDs must be non-empty strings.", index))
			elif seen_source_ids.has(String(source_id)):
				issues.append(_issue("boxing_event_duplicate_lineage", "%s.sourceEventIds[%d]" % [prefix, source_index], "Source event IDs must be unique.", index))
			else:
				seen_source_ids[String(source_id)] = true
	if beat_type in PUNCH_TYPES or beat_type == "guard":
		if not _exact_int(beat.get("timingWindowMs"), PROTOTYPE_TIMING_WINDOW_MS):
			issues.append(_issue("boxing_event_invalid_timing_window", "%s.timingWindowMs" % prefix, "Punch and guard timingWindowMs must be %d." % PROTOTYPE_TIMING_WINDOW_MS, index))
		if not _exact_int(beat.get("evidenceFreshnessMs"), FRESH_EVIDENCE_MS):
			issues.append(_issue("boxing_event_invalid_freshness", "%s.evidenceFreshnessMs" % prefix, "Punch and guard evidenceFreshnessMs must be %d." % FRESH_EVIDENCE_MS, index))
	if beat_type in PUNCH_TYPES:
		issues.append_array(_validate_punch(beat, beat_type, prefix, index))
	elif beat_type == "guard":
		issues.append_array(_validate_guard(beat, prefix, index))
		issues.append_array(_validate_checkpoint(beat, prefix, index))
	elif beat_type in CHECKPOINT_TYPES:
		issues.append_array(_validate_checkpoint(beat, prefix, index))
	return issues

static func _validate_punch(beat: Dictionary, beat_type: String, prefix: String, index: int) -> Array[Dictionary]:
	var issues: Array[Dictionary] = []
	var target: Variant = beat.get("spatialTarget")
	if not (target is Dictionary):
		return [_issue("boxing_punch_missing_spatial_target", "%s.spatialTarget" % prefix, "Prototype punches require spatialTarget.", index)]
	var spatial: Dictionary = target
	var cell_value: Variant = spatial.get("targetCell")
	var cell := int(cell_value) if cell_value is int else -1
	if not (cell_value is int) or cell < 0 or cell > 11:
		issues.append(_issue("boxing_punch_invalid_target_cell", "%s.spatialTarget.targetCell" % prefix, "Punch targetCell must be in 0..11.", index))
	var subcells: Variant = spatial.get("acceptedSubcells", [])
	if not (subcells is Array) or subcells.is_empty():
		issues.append(_issue("boxing_punch_missing_subcells", "%s.spatialTarget.acceptedSubcells" % prefix, "Punch acceptedSubcells must be non-empty.", index))
	else:
		var seen_subcells := {}
		for subcell in subcells:
			if not (subcell is int) or int(subcell) < 0 or int(subcell) > 47:
				issues.append(_issue("boxing_punch_invalid_subcell", "%s.spatialTarget.acceptedSubcells" % prefix, "Punch subcells must be integer IDs in 0..47.", index))
			elif seen_subcells.has(int(subcell)):
				issues.append(_issue("boxing_punch_duplicate_subcell", "%s.spatialTarget.acceptedSubcells" % prefix, "Punch acceptedSubcells must be unique.", index))
			else:
				seen_subcells[int(subcell)] = true
	var direction := String(spatial.get("entryDirection", ""))
	if beat_type.begins_with("straight_"):
		if not direction.is_empty() and not direction in CARDINAL_DIRECTIONS:
			issues.append(_issue("boxing_punch_invalid_direction", "%s.spatialTarget.entryDirection" % prefix, "Straight entryDirection must be cardinal when present.", index))
	elif not direction in CARDINAL_DIRECTIONS:
		issues.append(_issue("boxing_punch_invalid_direction", "%s.spatialTarget.entryDirection" % prefix, "Hook and uppercut entryDirection must be cardinal.", index))
	if beat_type.begins_with("straight_") and not _exact_int(spatial.get("qualificationMs"), STRAIGHT_QUALIFICATION_MS):
		issues.append(_issue("boxing_straight_invalid_qualification", "%s.spatialTarget.qualificationMs" % prefix, "Straight qualificationMs must be %d." % STRAIGHT_QUALIFICATION_MS, index))
	return issues

static func _validate_guard(beat: Dictionary, prefix: String, index: int) -> Array[Dictionary]:
	var guard: Variant = beat.get("guardTarget")
	if not (guard is Dictionary):
		return [_issue("boxing_guard_missing_target", "%s.guardTarget" % prefix, "Prototype guard requires guardTarget.", index)]
	var target: Dictionary = guard
	var left_value: Variant = target.get("leftCell")
	var right_value: Variant = target.get("rightCell")
	var crossed_value: Variant = target.get("crossed")
	var left_cell := int(left_value) if left_value is int else -1
	var right_cell := int(right_value) if right_value is int else -1
	var same_row := left_cell >= 0 and left_cell <= 11 and right_cell >= 0 and right_cell <= 11 and int(left_cell / 4) == int(right_cell / 4)
	if not same_row or abs(left_cell - right_cell) != 1:
		return [_issue("boxing_guard_invalid_pair", "%s.guardTarget" % prefix, "Guard cells must be an adjacent same-row pair.", index)]
	if not (crossed_value is bool):
		return [_issue("boxing_guard_invalid_crossed", "%s.guardTarget.crossed" % prefix, "Guard crossed must be a boolean.", index)]
	if bool(crossed_value) and String(beat.get("modifier", "")) != "crossed_guard":
		return [_issue("boxing_guard_crossed_modifier_missing", "%s.modifier" % prefix, "Crossed guard requires crossed_guard modifier.", index)]
	return []

static func _validate_checkpoint(beat: Dictionary, prefix: String, index: int) -> Array[Dictionary]:
	var checkpoint: Variant = beat.get("checkpoint")
	if not (checkpoint is Dictionary):
		return [_issue("boxing_checkpoint_missing", "%s.checkpoint" % prefix, "Defensive Boxing event requires checkpoint metadata.", index)]
	var data: Dictionary = checkpoint
	var issues: Array[Dictionary] = []
	if String(data.get("kind", "")) != "instantaneous":
		issues.append(_issue("boxing_checkpoint_invalid_kind", "%s.checkpoint.kind" % prefix, "Boxing checkpoint kind must be instantaneous.", index))
	if not _exact_int(data.get("freshnessMs"), FRESH_EVIDENCE_MS):
		issues.append(_issue("boxing_checkpoint_invalid_freshness", "%s.checkpoint.freshnessMs" % prefix, "Boxing checkpoint freshnessMs must be %d." % FRESH_EVIDENCE_MS, index))
	if not _exact_int(data.get("timingWindowMs"), PROTOTYPE_TIMING_WINDOW_MS):
		issues.append(_issue("boxing_checkpoint_invalid_timing_window", "%s.checkpoint.timingWindowMs" % prefix, "Boxing checkpoint timingWindowMs must be %d." % PROTOTYPE_TIMING_WINDOW_MS, index))
	if beat.has("blockedCells"):
		var cells: Variant = beat.get("blockedCells")
		if not (cells is Array) or cells.is_empty():
			issues.append(_issue("boxing_checkpoint_invalid_blocked_cells", "%s.blockedCells" % prefix, "Blocked cells must be a non-empty array when present.", index))
		else:
			var seen_cells := {}
			for cell in cells:
				if not (cell is int) or int(cell) < 0 or int(cell) > 11 or seen_cells.has(int(cell)):
					issues.append(_issue("boxing_checkpoint_invalid_blocked_cells", "%s.blockedCells" % prefix, "Blocked cells must be unique integer IDs in 0..11.", index))
				else:
					seen_cells[int(cell)] = true
	return issues

static func _exact_int(value: Variant, expected: int) -> bool:
	return value is int and int(value) == expected

static func _valid_sha256(value: Variant) -> bool:
	if not (value is String):
		return false
	var text := String(value)
	if not text.begins_with("sha256:") or text.length() != 71:
		return false
	for character in text.substr(7):
		if not String(character) in "0123456789abcdef":
			return false
	return true

static func _non_empty_string(value: Variant) -> bool:
	return value is String and not String(value).strip_edges().is_empty()

static func _issue(code: String, field: String, message: String, index: int = -1) -> Dictionary:
	var issue := {"code": code, "field": field, "message": message}
	if index >= 0:
		issue["index"] = index
	return issue
