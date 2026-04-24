class_name ContentPackageValidator
extends RefCounted

const ContentPackageManifest = preload("res://../data_types/content_package_manifest.gd")
const Routine = preload("res://../data_types/routine.gd")
const ChartVariant = preload("res://../data_types/chart_variant.gd")
const Workout = preload("res://../data_types/workout.gd")
const ContentValidationIssue = preload("res://../validators/content_validation_issue.gd")
const ContentValidationResult = preload("res://../validators/content_validation_result.gd")
const AeroContentSchema = preload("res://../globals/aero_content_schema.gd")

func validate_package(package_data: Dictionary) -> ContentValidationResult:
	var result := ContentValidationResult.new()
	var manifest := ContentPackageManifest.new(package_data.get("manifest", {}))
	if manifest.package_id == "":
		result.add_issue(ContentValidationIssue.new(ContentValidationIssue.SEVERITY_ERROR, "manifest.package_id_missing", "manifest.package_id", "Package id is required."))
	if manifest.schema != AeroContentSchema.package_schema_id():
		result.add_issue(ContentValidationIssue.new(ContentValidationIssue.SEVERITY_ERROR, "manifest.schema_invalid", "manifest.schema", "Manifest schema id does not match content-core expectations."))
	_validate_references(package_data, result)
	return result

func validate_fixture_path(package_path: String) -> ContentValidationResult:
	var normalized_path := package_path
	if package_path.begins_with("res://"):
		normalized_path = ProjectSettings.globalize_path(package_path)
	var package_data := _load_package(normalized_path)
	return validate_package(package_data)

func _validate_references(package_data: Dictionary, result: ContentValidationResult) -> void:
	var songs: Dictionary = package_data.get("songs", {})
	var routines: Dictionary = package_data.get("routines", {})
	var charts: Dictionary = package_data.get("charts", {})
	var workouts: Dictionary = package_data.get("workouts", {})

	for routine_id in routines.keys():
		var routine := Routine.new(routines[routine_id])
		if not songs.has(routine.song_id):
			result.add_issue(ContentValidationIssue.new(ContentValidationIssue.SEVERITY_ERROR, "routine.song_missing", "routines/%s.song_id" % routine_id, "Routine references missing song '%s'." % routine.song_id))

	for chart_id in charts.keys():
		var chart := ChartVariant.new(charts[chart_id])
		if not routines.has(chart.routine_id):
			result.add_issue(ContentValidationIssue.new(ContentValidationIssue.SEVERITY_ERROR, "chart.routine_missing", "charts/%s.routine_id" % chart_id, "Chart references missing routine '%s'." % chart.routine_id))

	for workout_id in workouts.keys():
		var workout := Workout.new(workouts[workout_id])
		for step_index in workout.steps.size():
			var step: Dictionary = workout.steps[step_index]
			var chart_id: String = str(step.get("chart_id", ""))
			if chart_id == "" or not charts.has(chart_id):
				result.add_issue(ContentValidationIssue.new(ContentValidationIssue.SEVERITY_ERROR, "workout.chart_missing", "workouts/%s.steps/%d.chart_id" % [workout_id, step_index], "Workout step references missing chart '%s'." % chart_id))

func _load_package(package_path: String) -> Dictionary:
	return {
		"manifest": _read_json("%s/manifest.json" % package_path),
		"songs": _load_folder_json("%s/songs" % package_path),
		"routines": _load_folder_json("%s/routines" % package_path),
		"charts": _load_folder_json("%s/charts" % package_path),
		"workouts": _load_folder_json("%s/workouts" % package_path),
	}

func _load_folder_json(folder_path: String) -> Dictionary:
	var output := {}
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return output
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			var json_path := "%s/%s" % [folder_path, file_name]
			var document: Dictionary = _read_json(json_path)
			output[document.get("id", file_name.trim_suffix(".json"))] = document
		file_name = dir.get_next()
	dir.list_dir_end()
	return output

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY:
		return parsed
	return {}
