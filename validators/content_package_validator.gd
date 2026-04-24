class_name ContentPackageValidator
extends RefCounted

const AeroContentSchema = preload("res://../globals/aero_content_schema.gd")
const ContentDifficulty = preload("res://../globals/content_difficulty.gd")
const ContentId = preload("res://../data_types/content_id.gd")
const ContentMode = preload("res://../globals/content_mode.gd")
const ContentPackageManifest = preload("res://../data_types/content_package_manifest.gd")
const ContentValidationIssue = preload("res://../validators/content_validation_issue.gd")
const ContentValidationResult = preload("res://../validators/content_validation_result.gd")
const InteractionFamily = preload("res://../globals/interaction_family.gd")
const Routine = preload("res://../data_types/routine.gd")
const Song = preload("res://../data_types/song.gd")
const Chart = preload("res://../data_types/chart.gd")
const Workout = preload("res://../data_types/workout.gd")

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
		"routines": _load_records(package_dir, manifest.get("routines", [])),
		"charts": _load_records(package_dir, manifest.get("charts", [])),
		"workouts": _load_records(package_dir, manifest.get("workouts", [])),
	}
	return validate_package_data(package_data)

func validate_package_data(package_data: Dictionary) -> ContentValidationResult:
	var result := ContentValidationResult.new()
	var manifest: Dictionary = package_data.get("manifest", {})
	_validate_manifest(manifest, result)
	_validate_records(package_data.get("songs", []), Song, "song", result)
	_validate_records(package_data.get("routines", []), Routine, "routine", result)
	_validate_records(package_data.get("charts", []), Chart, "chart", result)
	_validate_records(package_data.get("workouts", []), Workout, "workout", result)
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
				"%s is missing required field '%s'." % [kind.capitalize(), field],
				path,
				{"kind": kind}
			))
		if kind == "workout":
			for issue in Workout.validate_steps_shape(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "workout_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Workout contract issue.")),
					_path_with_step_context(path, issue),
					_workout_issue_reference(issue)
				))
		var schema_id := String(data.get("schema", ""))
		if not AeroContentSchema.is_known_record_schema(schema_id):
			result.add_issue(ContentValidationIssue.create(
				"record_unknown_schema",
				ContentValidationIssue.SEVERITY_ERROR,
				"%s schema '%s' is not recognized." % [kind.capitalize(), schema_id],
				path,
				{"kind": kind}
			))
		var id_key := _id_key_for_kind(kind)
		var record_id := String(data.get(id_key, ""))
		if not ContentId.is_valid_uid(record_id):
			result.add_issue(ContentValidationIssue.create(
				"invalid_uid",
				ContentValidationIssue.SEVERITY_ERROR,
				"%s field '%s' must be a stable lowercase UID." % [kind.capitalize(), id_key],
				path,
				{"kind": kind, "id": record_id}
			))
		elif seen_ids.has(record_id):
			result.add_issue(ContentValidationIssue.create(
				"duplicate_id",
				ContentValidationIssue.SEVERITY_ERROR,
				"Duplicate %s id '%s'." % [kind, record_id],
				path,
				{"kind": kind, "id": record_id}
			))
		else:
			seen_ids[record_id] = path
		if kind == "routine" and not ContentMode.is_valid(String(data.get("mode", ""))):
			result.add_issue(ContentValidationIssue.create(
				"invalid_mode",
				ContentValidationIssue.SEVERITY_ERROR,
				"Routine mode must be one of the canonical content modes.",
				path
			))
		if kind == "chart":
			if not ContentMode.is_valid(String(data.get("mode", ""))):
				result.add_issue(ContentValidationIssue.create(
					"invalid_mode",
					ContentValidationIssue.SEVERITY_ERROR,
					"Chart mode must be one of the canonical content modes.",
					path
				))
			if not ContentDifficulty.is_valid(String(data.get("difficulty", ""))):
				result.add_issue(ContentValidationIssue.create(
					"invalid_difficulty",
					ContentValidationIssue.SEVERITY_ERROR,
					"Chart difficulty must be one of easy/medium/hard/pro.",
					path
				))
			if not InteractionFamily.is_valid(String(data.get("interactionFamily", ""))):
				result.add_issue(ContentValidationIssue.create(
					"invalid_interaction_family",
					ContentValidationIssue.SEVERITY_ERROR,
					"Chart interactionFamily must be one of the canonical interaction families.",
					path
				))

func _validate_references(package_data: Dictionary, result: ContentValidationResult) -> void:
	var songs_by_id := _index_records(package_data.get("songs", []), "songId")
	var routines_by_id := _index_records(package_data.get("routines", []), "routineId")
	var charts_by_id := _index_records(package_data.get("charts", []), "chartId")
	for routine_record in package_data.get("routines", []):
		var routine: Dictionary = routine_record.get("data", {})
		if not songs_by_id.has(String(routine.get("songId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_song_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Routine references a songId that is not present in the package.",
				String(routine_record.get("path", "")),
				{"songId": routine.get("songId", "")}
			))
		for chart_id in routine.get("charts", []):
			if not charts_by_id.has(String(chart_id)):
				result.add_issue(ContentValidationIssue.create(
					"missing_chart_ref",
					ContentValidationIssue.SEVERITY_ERROR,
					"Routine charts list references a chartId that is not present in the package.",
					String(routine_record.get("path", "")),
					{"chartId": chart_id}
				))
	for chart_record in package_data.get("charts", []):
		var chart: Dictionary = chart_record.get("data", {})
		if not routines_by_id.has(String(chart.get("routineId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_routine_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Chart references a routineId that is not present in the package.",
				String(chart_record.get("path", "")),
				{"routineId": chart.get("routineId", "")}
			))
		if not songs_by_id.has(String(chart.get("songId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_song_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Chart references a songId that is not present in the package.",
				String(chart_record.get("path", "")),
				{"songId": chart.get("songId", "")}
			))
	for workout_record in package_data.get("workouts", []):
		var workout: Dictionary = workout_record.get("data", {})
		_validate_workout_steps(
			workout,
			String(workout_record.get("path", "")),
			charts_by_id,
			result
		)

func _validate_workout_steps(workout: Dictionary, workout_path: String, charts_by_id: Dictionary, result: ContentValidationResult) -> void:
	var steps_value: Variant = workout.get("steps", [])
	if not (steps_value is Array):
		return
	var seen_step_ids: Dictionary = {}
	for index in range(steps_value.size()):
		var step_value: Variant = steps_value[index]
		if not (step_value is Dictionary):
			continue
		var step: Dictionary = step_value
		var step_path := _step_path(workout_path, index, step)
		var step_id := String(step.get("stepId", ""))
		if not step_id.is_empty():
			if seen_step_ids.has(step_id):
				result.add_issue(ContentValidationIssue.create(
					"duplicate_workout_step_id",
					ContentValidationIssue.SEVERITY_ERROR,
					"Workout stepId '%s' must be unique within a workout." % step_id,
					step_path,
					{"stepId": step_id, "workoutId": String(workout.get("workoutId", ""))}
				))
			else:
				seen_step_ids[step_id] = index
		var chart_id := String(step.get("chartId", ""))
		if chart_id.is_empty():
			continue
		if not charts_by_id.has(chart_id):
			result.add_issue(ContentValidationIssue.create(
				"missing_chart_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Workout step references a chartId that is not present in the package.",
				step_path,
				{"chartId": chart_id, "stepId": step_id}
			))
			continue
		var chart: Dictionary = charts_by_id[chart_id].get("data", {})
		if step.has("songId") and String(step.get("songId", "")) != String(chart.get("songId", "")):
			result.add_issue(ContentValidationIssue.create(
				"workout_step_song_mismatch",
				ContentValidationIssue.SEVERITY_ERROR,
				"Workout step songId must match the referenced chart songId.",
				step_path,
				{
					"stepId": step_id,
					"chartId": chart_id,
					"songId": step.get("songId", ""),
					"expectedSongId": chart.get("songId", ""),
				}
			))
		if step.has("routineId") and String(step.get("routineId", "")) != String(chart.get("routineId", "")):
			result.add_issue(ContentValidationIssue.create(
				"workout_step_routine_mismatch",
				ContentValidationIssue.SEVERITY_ERROR,
				"Workout step routineId must match the referenced chart routineId.",
				step_path,
				{
					"stepId": step_id,
					"chartId": chart_id,
					"routineId": step.get("routineId", ""),
					"expectedRoutineId": chart.get("routineId", ""),
				}
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
		"routine":
			return "routineId"
		"chart":
			return "chartId"
		"workout":
			return "workoutId"
		_:
			return "id"

func _path_with_step_context(path: String, issue: Dictionary) -> String:
	return _step_path(path, int(issue.get("index", -1)), {"stepId": issue.get("stepId", "")})

func _workout_issue_reference(issue: Dictionary) -> Dictionary:
	var reference: Dictionary = {}
	if issue.has("field"):
		reference["field"] = issue.get("field")
	if issue.has("index"):
		reference["stepIndex"] = issue.get("index")
	if issue.has("stepId"):
		reference["stepId"] = issue.get("stepId")
	return reference

func _step_path(workout_path: String, index: int, step: Dictionary) -> String:
	var suffix := "steps[%d]" % index
	var step_id := String(step.get("stepId", ""))
	if not step_id.is_empty():
		suffix += "(%s)" % step_id
	return "%s#%s" % [workout_path, suffix]
