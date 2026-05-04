class_name ContentPackageValidator
extends RefCounted

const AeroContentSchema = preload("res://../globals/aero_content_schema.gd")
const ContentDifficulty = preload("res://../globals/content_difficulty.gd")
const ContentId = preload("res://../data_types/content_id.gd")
const ContentFeature = preload("res://../globals/content_feature.gd")
const ContentPackageManifest = preload("res://../data_types/content_package_manifest.gd")
const ContentValidationIssue = preload("res://../validators/content_validation_issue.gd")
const ContentValidationResult = preload("res://../validators/content_validation_result.gd")
const Song = preload("res://../data_types/song.gd")
const Chart = preload("res://../data_types/chart.gd")
const ContentSet = preload("res://../data_types/content_set.gd")
const Workout = preload("res://../data_types/workout.gd")
const CoachConfig = preload("res://../data_types/coach_config.gd")
const EnvironmentRecord = preload("res://../data_types/environment.gd")

func validate_fixture_package(package_dir: String) -> ContentValidationResult:
	var manifest_path := package_dir.path_join("manifest.json")
	var manifest := _load_json(manifest_path)
	if manifest.is_empty():
		var missing_result := ContentValidationResult.new()
		missing_result.add_issue(ContentValidationIssue.create(
			"manifest_missing",
			ContentValidationIssue.SEVERITY_ERROR,
			"Package manifest could not be loaded.",
			manifest_path
		))
		return missing_result
	var package_data := {
		"manifest": manifest,
		"songs": _load_records(package_dir, manifest.get("songs", [])),
		"charts": _load_records(package_dir, manifest.get("charts", [])),
		"sets": _load_records(package_dir, manifest.get("sets", [])),
		"workouts": _load_records(package_dir, manifest.get("workouts", [])),
		"coaches": _load_records(package_dir, manifest.get("coaches", [])),
		"environments": _load_records(package_dir, manifest.get("environments", [])),
	}
	return validate_package_data(package_data)

func validate_package_data(package_data: Dictionary) -> ContentValidationResult:
	var result := ContentValidationResult.new()
	var manifest: Dictionary = package_data.get("manifest", {})
	_validate_manifest(manifest, result)
	_validate_records(package_data.get("songs", []), Song, "song", result)
	_validate_records(package_data.get("charts", []), Chart, "chart", result)
	_validate_records(package_data.get("sets", []), ContentSet, "set", result)
	_validate_records(package_data.get("workouts", []), Workout, "workout", result)
	_validate_records(package_data.get("coaches", []), CoachConfig, "coach_config", result)
	_validate_records(package_data.get("environments", []), EnvironmentRecord, "environment", result)
	_validate_references(package_data, result)
	return result

func _validate_manifest(manifest: Dictionary, result: ContentValidationResult) -> void:
	for field in ContentPackageManifest.validate_shape(manifest):
		result.add_issue(ContentValidationIssue.create(
			"manifest_missing_field",
			ContentValidationIssue.SEVERITY_ERROR,
			"Manifest is missing required field '%s'." % field,
			"manifest"
		))
	for field in ContentPackageManifest.forbidden_fields_present(manifest):
		result.add_issue(ContentValidationIssue.create(
			"manifest_forbidden_field",
			ContentValidationIssue.SEVERITY_ERROR,
			"Manifest field '%s' is legacy contract data and must not be present." % field,
			"manifest.%s" % field
		))
	var schema_id := String(manifest.get("schema", ""))
	if not AeroContentSchema.is_known_schema(schema_id):
		result.add_issue(ContentValidationIssue.create(
			"manifest_unknown_schema",
			ContentValidationIssue.SEVERITY_ERROR,
			"Manifest schema '%s' is not recognized." % schema_id,
			"manifest.schema"
		))
	if not ContentId.is_valid_uid(manifest.get("packageId", "")):
		result.add_issue(ContentValidationIssue.create(
			"manifest_invalid_package_id",
			ContentValidationIssue.SEVERITY_ERROR,
			"Manifest packageId must be a stable lowercase UID.",
			"manifest.packageId"
		))

func _validate_records(records: Array, contract_script: GDScript, kind: String, result: ContentValidationResult) -> void:
	var seen_ids: Dictionary = {}
	for record in records:
		var data: Dictionary = record.get("data", {})
		var path: String = String(record.get("path", kind))
		for field in contract_script.validate_shape(data):
			result.add_issue(ContentValidationIssue.create(
				"required_field_missing",
				ContentValidationIssue.SEVERITY_ERROR,
				"%s is missing required field '%s'." % [_kind_label(kind), field],
				path,
				{"kind": kind}
			))
		if kind == "song":
			for issue in Song.validate_timing_shape(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "song_timing_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Song timing contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
		if kind == "workout":
			for issue in Workout.validate_set_order_shape(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "workout_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Workout contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
		var schema_id := String(data.get("schema", ""))
		if not AeroContentSchema.is_known_record_schema(schema_id):
			result.add_issue(ContentValidationIssue.create(
				"record_unknown_schema",
				ContentValidationIssue.SEVERITY_ERROR,
				"%s schema '%s' is not recognized." % [_kind_label(kind), schema_id],
				path,
				{"kind": kind}
			))
		var id_key := _id_key_for_kind(kind)
		var record_id := String(data.get(id_key, ""))
		if not record_id.is_empty() and not ContentId.is_valid_uid(record_id):
			result.add_issue(ContentValidationIssue.create(
				"invalid_uid",
				ContentValidationIssue.SEVERITY_ERROR,
				"%s field '%s' must be a stable lowercase UID." % [_kind_label(kind), id_key],
				path,
				{"kind": kind, "id": record_id}
			))
		elif not record_id.is_empty():
			if seen_ids.has(record_id):
				result.add_issue(ContentValidationIssue.create(
					"duplicate_id",
					ContentValidationIssue.SEVERITY_ERROR,
					"Duplicate %s id '%s'." % [kind, record_id],
					path,
					{"kind": kind, "id": record_id}
				))
			else:
				seen_ids[record_id] = path
		if kind == "chart":
			for issue in Chart.validate_contract(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "chart_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Chart contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
			if not ContentFeature.is_valid(String(data.get("feature", ""))):
				result.add_issue(ContentValidationIssue.create(
					"invalid_feature",
					ContentValidationIssue.SEVERITY_ERROR,
					"Chart feature must be one of the canonical v1 content features (boxing or flow).",
					path
				))
			if not ContentDifficulty.is_valid(String(data.get("difficulty", ""))):
				result.add_issue(ContentValidationIssue.create(
					"invalid_difficulty",
					ContentValidationIssue.SEVERITY_ERROR,
					"Chart difficulty must be one of easy/medium/hard/pro.",
					path
				))
		if kind == "environment":
			for issue in EnvironmentRecord.validate_contract(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "environment_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Environment contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
		if kind == "coach_config":
			for issue in CoachConfig.validate_contract(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "coach_config_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Coach config contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))

func _validate_references(package_data: Dictionary, result: ContentValidationResult) -> void:
	var songs_by_id := _index_records(package_data.get("songs", []), "songId")
	var charts_by_id := _index_records(package_data.get("charts", []), "chartId")
	var sets_by_id := _index_records(package_data.get("sets", []), "setId")
	var coaches_by_id := _index_records(package_data.get("coaches", []), "coachConfigId")
	var environments_by_id := _index_records(package_data.get("environments", []), "environmentId")
	for set_record in package_data.get("sets", []):
		var set_data: Dictionary = set_record.get("data", {})
		var set_path := String(set_record.get("path", ""))
		if not songs_by_id.has(String(set_data.get("songId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_song_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Set references a songId that is not present in the package.",
				set_path,
				{"songId": set_data.get("songId", "")}
			))
		if not charts_by_id.has(String(set_data.get("chartId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_chart_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Set references a chartId that is not present in the package.",
				set_path,
				{"chartId": set_data.get("chartId", "")}
			))
		if not environments_by_id.has(String(set_data.get("environmentId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_environment_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Set references an environmentId that is not present in the package.",
				set_path,
				{"environmentId": set_data.get("environmentId", "")}
			))
	for workout_record in package_data.get("workouts", []):
		var workout: Dictionary = workout_record.get("data", {})
		var workout_path := String(workout_record.get("path", ""))
		var coach_config_id := String(workout.get("coachConfigId", ""))
		var coach_config: Dictionary = {}
		if not coaches_by_id.has(coach_config_id):
			result.add_issue(ContentValidationIssue.create(
				"missing_coach_config_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Workout references a coachConfigId that is not present in the package.",
				workout_path,
				{"coachConfigId": coach_config_id}
			))
		else:
			coach_config = coaches_by_id[coach_config_id].get("data", {})
		var set_order_value: Variant = workout.get("setOrder", [])
		if not (set_order_value is Array):
			continue
		var seen_set_ids: Dictionary = {}
		for index in range(set_order_value.size()):
			var set_id := String(set_order_value[index])
			var set_path := "%s#setOrder[%d]" % [workout_path, index]
			if set_id.is_empty():
				continue
			if seen_set_ids.has(set_id):
				result.add_issue(ContentValidationIssue.create(
					"duplicate_set_order_id",
					ContentValidationIssue.SEVERITY_ERROR,
					"Workout setOrder contains duplicate set id '%s'." % set_id,
					set_path,
					{"setId": set_id}
				))
			else:
				seen_set_ids[set_id] = index
			if not sets_by_id.has(set_id):
				result.add_issue(ContentValidationIssue.create(
					"missing_set_ref",
					ContentValidationIssue.SEVERITY_ERROR,
					"Workout setOrder references a setId that is not present in the package.",
					set_path,
					{"setId": set_id}
				))
				continue
			var set_data: Dictionary = sets_by_id[set_id].get("data", {})
			_validate_coaching_overlay_reference(set_data, coach_config, set_path, result)

func _validate_coaching_overlay_reference(set_data: Dictionary, coach_config: Dictionary, path: String, result: ContentValidationResult) -> void:
	if coach_config.is_empty():
		return
	var enabled := bool(coach_config.get("enabled", false))
	var overlay_id := String(set_data.get("coachingOverlayId", ""))
	if not enabled:
		if not overlay_id.is_empty():
			result.add_issue(ContentValidationIssue.create(
				"unexpected_coaching_overlay_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Set references coachingOverlayId while coaching is disabled.",
				path,
				{"coachingOverlayId": overlay_id}
			))
		return
	if overlay_id.is_empty():
		result.add_issue(ContentValidationIssue.create(
			"missing_required_coaching_overlay_ref",
			ContentValidationIssue.SEVERITY_ERROR,
			"Set must declare coachingOverlayId when coaching is enabled.",
			path
		))
		return
	var overlays_by_id := CoachConfig.overlay_audio_index(coach_config)
	if not overlays_by_id.has(overlay_id):
		result.add_issue(ContentValidationIssue.create(
			"missing_coaching_overlay_ref",
			ContentValidationIssue.SEVERITY_ERROR,
			"Set references a coachingOverlayId that is not present in the coach config.",
			path,
			{"coachingOverlayId": overlay_id}
		))

func _load_records(package_dir: String, manifest_entries: Array) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for entry in manifest_entries:
		var relative_path := String(entry.get("path", ""))
		var absolute_path := package_dir.path_join(relative_path)
		records.append({
			"path": relative_path,
			"data": _load_json(absolute_path),
		})
	return records

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return {}
	return parsed

func _index_records(records: Array, id_key: String) -> Dictionary:
	var index: Dictionary = {}
	for record in records:
		var data: Dictionary = record.get("data", {})
		var record_id := String(data.get(id_key, ""))
		if not record_id.is_empty():
			index[record_id] = record
	return index

func _id_key_for_kind(kind: String) -> String:
	match kind:
		"song":
			return "songId"
		"chart":
			return "chartId"
		"set":
			return "setId"
		"workout":
			return "workoutId"
		"coach_config":
			return "coachConfigId"
		"environment":
			return "environmentId"
		_:
			return "id"

func _kind_label(kind: String) -> String:
	match kind:
		"coach_config":
			return "Coach config"
		_:
			return kind.capitalize()

func _path_with_issue_context(path: String, issue: Dictionary) -> String:
	var field := String(issue.get("field", ""))
	if field.is_empty():
		return path
	return "%s#%s" % [path, field]

func _issue_reference(issue: Dictionary) -> Dictionary:
	var reference: Dictionary = {}
	if issue.has("field"):
		reference["field"] = issue.get("field")
	if issue.has("index"):
		reference["index"] = issue.get("index")
	return reference
