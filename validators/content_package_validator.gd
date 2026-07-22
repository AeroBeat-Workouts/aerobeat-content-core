class_name ContentPackageValidator
extends RefCounted

# Canonical authored package truth now lives in song.package.yaml-centered YAML docs.
# Legacy manifest.json fixtures still exist for isolated compatibility coverage, but
# the default imported-player contract is now the simpler song-package model: one
# embedded root song, many exact root charts[] slices, with no required package-local
# coaching or environment ownership. The older workout.yaml root alias is retired.
const AeroContentSchema = preload("res://addons/aerobeat-content-core/globals/aero_content_schema.gd")
const ContentDifficulty = preload("res://addons/aerobeat-content-core/globals/content_difficulty.gd")
const ContentId = preload("res://addons/aerobeat-content-core/data_types/content_id.gd")
const ContentFeature = preload("res://addons/aerobeat-content-core/globals/content_feature.gd")
const ContentPackageManifest = preload("res://addons/aerobeat-content-core/data_types/content_package_manifest.gd")
const ContentValidationIssue = preload("res://addons/aerobeat-content-core/validators/content_validation_issue.gd")
const ContentValidationResult = preload("res://addons/aerobeat-content-core/validators/content_validation_result.gd")
const SongPackage = preload("res://addons/aerobeat-content-core/data_types/song_package.gd")
const Song = preload("res://addons/aerobeat-content-core/data_types/song.gd")
const Chart = preload("res://addons/aerobeat-content-core/data_types/chart.gd")
const ContentSet = preload("res://addons/aerobeat-content-core/data_types/content_set.gd")
const Workout = preload("res://addons/aerobeat-content-core/data_types/workout.gd")
const CoachConfig = preload("res://addons/aerobeat-content-core/data_types/coach_config.gd")
const EnvironmentRecord = preload("res://addons/aerobeat-content-core/data_types/environment.gd")
const SimpleYamlParser = preload("res://addons/aerobeat-content-core/validators/simple_yaml_parser.gd")

func validate_fixture_package(package_dir: String) -> Object:
	if FileAccess.file_exists(package_dir.path_join("song.package.yaml")):
		return validate_song_package_yaml_package(package_dir)
	if FileAccess.file_exists(package_dir.path_join("workout.yaml")):
		var retired_result: Variant = ContentValidationResult.new()
		retired_result.add_issue(ContentValidationIssue.create(
			"retired_workout_yaml_root",
			ContentValidationIssue.SEVERITY_ERROR,
			"workout.yaml is retired. Rename the package root to song.package.yaml.",
			package_dir.path_join("workout.yaml")
		))
		return retired_result
	return validate_legacy_manifest_fixture_package(package_dir)

func validate_song_package_yaml_package(package_dir: String) -> Object:
	var package_result: Dictionary = _load_song_package_yaml_package_data(package_dir, "song.package.yaml")
	var load_result: Variant = package_result.get("result", ContentValidationResult.new())
	if not load_result.is_valid():
		return load_result
	return validate_song_package_data(package_result.get("package_data", {}))

func validate_legacy_manifest_fixture_package(package_dir: String) -> Object:
	var manifest_path := package_dir.path_join("manifest.json")
	var manifest := _load_json(manifest_path)
	if manifest.is_empty():
		var missing_result: Variant = ContentValidationResult.new()
		missing_result.add_issue(ContentValidationIssue.create(
			"manifest_missing",
			ContentValidationIssue.SEVERITY_ERROR,
			"Legacy manifest.json fixture package could not be loaded.",
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
	return validate_legacy_package_data(package_data)

func validate_song_package_data(package_data: Dictionary) -> Object:
	var result: Variant = ContentValidationResult.new()
	_validate_records(package_data.get("song_packages", []), SongPackage, "song_package", result)
	_validate_records(package_data.get("songs", []), Song, "song", result)
	_validate_records(package_data.get("charts", []), Chart, "chart", result)
	_validate_records(package_data.get("sets", []), ContentSet, "set", result, true)
	_validate_song_package_references(package_data, result)
	return result

func validate_legacy_package_data(package_data: Dictionary) -> Object:
	var result: Variant = ContentValidationResult.new()
	var manifest: Dictionary = package_data.get("manifest", {})
	_validate_manifest(manifest, result)
	_validate_records(package_data.get("songs", []), Song, "song", result)
	_validate_records(package_data.get("charts", []), Chart, "chart", result)
	_validate_records(package_data.get("sets", []), ContentSet, "set", result, false)
	_validate_records(package_data.get("workouts", []), Workout, "workout", result)
	_validate_records(package_data.get("coaches", []), CoachConfig, "coach_config", result)
	_validate_records(package_data.get("environments", []), EnvironmentRecord, "environment", result)
	_validate_legacy_references(package_data, result)
	return result

func _load_song_package_yaml_package_data(package_dir: String, root_file_name: String) -> Dictionary:
	var result: Variant = ContentValidationResult.new()
	var root_path := package_dir.path_join(root_file_name)
	var root_record := _load_yaml(root_path)
	if root_record.is_empty():
		result.add_issue(ContentValidationIssue.create(
			"song_package_yaml_missing",
			ContentValidationIssue.SEVERITY_ERROR,
			"Canonical song.package.yaml package could not be loaded.",
			root_path
		))
		return {"result": result, "package_data": {}}
	var song_package := _normalize_root_song_package_record(root_record)
	return {
		"result": result,
		"package_data": {
			"song_packages": [{"path": root_file_name, "data": song_package}],
			"songs": _root_song_records(song_package),
			"charts": _load_yaml_chart_records_from_root(package_dir, song_package),
			"sets": _derive_sets_from_root(song_package),
		}
	}

func _load_yaml_records_from_dir(package_dir: String, relative_dir: String) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	var absolute_dir := package_dir.path_join(relative_dir)
	if not DirAccess.dir_exists_absolute(absolute_dir):
		return records
	var dir := DirAccess.open(absolute_dir)
	if dir == null:
		return records
	var file_names: Array[String] = []
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name.is_empty():
			break
		if dir.current_is_dir():
			continue
		if file_name.ends_with(".yaml") or file_name.ends_with(".yml"):
			file_names.append(file_name)
	dir.list_dir_end()
	file_names.sort()
	var kind := _yaml_dir_kind(relative_dir)
	for file_name in file_names:
		var relative_path := relative_dir.path_join(file_name)
		var absolute_path := package_dir.path_join(relative_path)
		records.append({
			"path": relative_path,
			"data": _normalize_yaml_record(_load_yaml(absolute_path), kind),
		})
	return records


func _root_song_records(song_package: Dictionary) -> Array[Dictionary]:
	var song_record: Dictionary = Dictionary(song_package.get("song", {})).duplicate(true)
	if song_record.is_empty():
		return []
	return [{"path": "song.package.yaml#song", "data": song_record}]

func _load_yaml_chart_records_from_root(package_dir: String, song_package: Dictionary) -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for descriptor_variant in song_package.get("charts", []):
		if not (descriptor_variant is Dictionary):
			continue
		var descriptor := Dictionary(descriptor_variant)
		var relative_path := String(descriptor.get("path", "")).strip_edges()
		if relative_path.is_empty():
			continue
		var absolute_path := package_dir.path_join(relative_path)
		records.append({
			"path": relative_path,
			"data": _normalize_yaml_record(_load_yaml(absolute_path), "chart"),
		})
	return records

func _derive_sets_from_root(song_package: Dictionary) -> Array[Dictionary]:
	var sets: Array[Dictionary] = []
	var song: Dictionary = Dictionary(song_package.get("song", {})).duplicate(true)
	var song_id := String(song.get("songId", "")).strip_edges()
	var index := 0
	for descriptor_variant in song_package.get("charts", []):
		if not (descriptor_variant is Dictionary):
			continue
		var descriptor := Dictionary(descriptor_variant)
		sets.append({
			"path": "song.package.yaml#charts[%d]" % index,
			"data": {
				"schema": AeroContentSchema.SET_V1,
				"setId": String(descriptor.get("setId", "")).strip_edges(),
				"setName": String(descriptor.get("setName", "")).strip_edges(),
				"songId": song_id,
				"chartId": String(descriptor.get("chartId", "")).strip_edges(),
			},
		})
		index += 1
	return sets

func _normalize_root_song_package_record(record: Dictionary) -> Dictionary:
	var normalized := record.duplicate(true)
	normalized["schema"] = AeroContentSchema.SONG_PACKAGE_V1
	if normalized.get("song") is Dictionary:
		normalized["song"] = _normalize_yaml_record(Dictionary(normalized.get("song", {})), "song")
	var normalized_chart_descriptors: Array = []
	for entry in normalized.get("charts", []):
		if not (entry is Dictionary):
			continue
		var descriptor := Dictionary(entry).duplicate(true)
		descriptor["setId"] = String(descriptor.get("setId", "")).strip_edges()
		descriptor["setName"] = String(descriptor.get("setName", "")).strip_edges()
		descriptor["chartId"] = String(descriptor.get("chartId", "")).strip_edges()
		descriptor["path"] = String(descriptor.get("path", "")).strip_edges()
		normalized_chart_descriptors.append(descriptor)
	normalized["charts"] = normalized_chart_descriptors
	return normalized

func _normalize_yaml_record(record: Dictionary, kind: String) -> Dictionary:
	var normalized := record.duplicate(true)
	if normalized.is_empty():
		return normalized
	if normalized.has("schemaId"):
		normalized["schema"] = _normalized_schema_for_record(kind, String(normalized.get("schemaId", "")))
	if kind == "song":
		var audio_value: Variant = normalized.get("audio", {})
		if audio_value is Dictionary:
			var audio := Dictionary(audio_value).duplicate(true)
			if audio.has("filePath") and not audio.has("resourcePath"):
				audio["resourcePath"] = audio.get("filePath")
			if audio.has("previewFilePath") and not audio.has("previewResourcePath"):
				audio["previewResourcePath"] = audio.get("previewFilePath")
			normalized["audio"] = audio
			if not normalized.has("durationSec") and audio.has("durationMs"):
				var duration_ms := float(audio.get("durationMs", 0))
				normalized["durationSec"] = int(ceili(duration_ms / 1000.0))
	return normalized

func _normalized_schema_for_record(kind: String, schema_id: String) -> String:
	match kind:
		"song_package":
			return AeroContentSchema.SONG_PACKAGE_V1
		"song":
			return AeroContentSchema.SONG_V1
		"chart":
			return AeroContentSchema.CHART_V1
		"set":
			return AeroContentSchema.SET_V1
		"workout":
			return AeroContentSchema.WORKOUT_V1
		"coach_config":
			return AeroContentSchema.COACH_CONFIG_V1
		"environment":
			return AeroContentSchema.ENVIRONMENT_V1
		_:
			return schema_id

func _yaml_dir_kind(relative_dir: String) -> String:
	match relative_dir:
		"songs":
			return "song"
		"charts":
			return "chart"
		"sets":
			return "set"
		"coaches":
			return "coach_config"
		"environments":
			return "environment"
		_:
			return relative_dir

func _validate_manifest(manifest: Dictionary, result) -> void:
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

func _validate_records(records: Array, contract_script: GDScript, kind: String, result, enforce_current_contract: bool = true) -> void:
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
			for issue in Song.validate_audio_shape(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "song_audio_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Song audio contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
			for issue in Song.validate_timing_shape(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "song_timing_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Song timing contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
		if kind == "song_package":
			for issue in SongPackage.validate_contract(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "song_package_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Song package contract issue.")),
					_path_with_issue_context(path, issue),
					_issue_reference(issue)
				))
		if kind == "set" and enforce_current_contract:
			for issue in ContentSet.validate_contract(data):
				result.add_issue(ContentValidationIssue.create(
					String(issue.get("code", "set_contract_issue")),
					ContentValidationIssue.SEVERITY_ERROR,
					String(issue.get("message", "Set contract issue.")),
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
					"Chart difficulty must be one of Easy/Normal/Hard/Expert/ExpertPlus.",
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

func _validate_song_package_references(package_data: Dictionary, result) -> void:
	var songs_by_id := _index_records(package_data.get("songs", []), "songId")
	var charts_by_id := _index_records(package_data.get("charts", []), "chartId")
	var sets_by_id := _index_records(package_data.get("sets", []), "setId")
	for set_record in package_data.get("sets", []):
		var set_data: Dictionary = set_record.get("data", {})
		var set_path := String(set_record.get("path", ""))
		if not songs_by_id.has(String(set_data.get("songId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_song_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Root charts[] descriptor references a songId that is not present in the package.",
				set_path,
				{"songId": set_data.get("songId", "")}
			))
		if not charts_by_id.has(String(set_data.get("chartId", ""))):
			result.add_issue(ContentValidationIssue.create(
				"missing_chart_ref",
				ContentValidationIssue.SEVERITY_ERROR,
				"Root charts[] descriptor references a chartId that is not present in the package.",
				set_path,
				{"chartId": set_data.get("chartId", "")}
			))
	var referenced_chart_ids: Dictionary = {}
	for package_record in package_data.get("song_packages", []):
		var song_package: Dictionary = package_record.get("data", {})
		var package_path := String(package_record.get("path", ""))
		var chart_entries: Variant = song_package.get("charts", [])
		if not (chart_entries is Array):
			continue
		var seen_set_ids: Dictionary = {}
		for index in range(chart_entries.size()):
			if not (chart_entries[index] is Dictionary):
				continue
			var descriptor := Dictionary(chart_entries[index])
			var set_id := String(descriptor.get("setId", "")).strip_edges()
			var chart_id := String(descriptor.get("chartId", "")).strip_edges()
			var descriptor_path := "%s#charts[%d]" % [package_path, index]
			if not set_id.is_empty():
				if seen_set_ids.has(set_id):
					result.add_issue(ContentValidationIssue.create(
						"duplicate_song_package_set_id",
						ContentValidationIssue.SEVERITY_ERROR,
						"Root charts contains duplicate set id '%s'." % set_id,
						descriptor_path,
						{"setId": set_id}
					))
				else:
					seen_set_ids[set_id] = index
				if not sets_by_id.has(set_id):
					result.add_issue(ContentValidationIssue.create(
						"missing_set_ref",
						ContentValidationIssue.SEVERITY_ERROR,
						"Root charts references a setId that is not present in the package.",
						descriptor_path,
						{"setId": set_id}
					))
			if not chart_id.is_empty():
				referenced_chart_ids[chart_id] = true
	for chart_record in package_data.get("charts", []):
		var chart_data: Dictionary = chart_record.get("data", {})
		var chart_id := String(chart_data.get("chartId", "")).strip_edges()
		var chart_path := String(chart_record.get("path", ""))
		if not chart_id.is_empty() and not referenced_chart_ids.has(chart_id):
			result.add_issue(ContentValidationIssue.create(
				"orphan_chart_record",
				ContentValidationIssue.SEVERITY_ERROR,
				"Chart file is present on disk but is not referenced from root charts[].",
				chart_path,
				{"chartId": chart_id}
			))

func _validate_legacy_references(package_data: Dictionary, result) -> void:
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

func _validate_coaching_overlay_reference(set_data: Dictionary, coach_config: Dictionary, path: String, result) -> void:
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
	var overlays_by_id: Dictionary = CoachConfig.overlay_audio_index(coach_config)
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

func _load_yaml(path: String) -> Dictionary:
	var parser = SimpleYamlParser.new()
	var parsed: Variant = parser.parse_file(path)
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
		"song_package":
			return "songPackageId"
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
		"song_package":
			return "Song package"
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
