class_name AeroContentSchema
extends RefCounted

const FAMILY := "aerobeat.content"
const VERSION := 1
const MANIFEST_TYPE := "content_package_manifest"
const SONG_TYPE := "song"
const ROUTINE_TYPE := "routine"
const CHART_TYPE := "chart_variant"
const WORKOUT_TYPE := "workout"

static func schema_id(type_name: String) -> String:
	return "%s.%s.v%d" % [FAMILY, type_name, VERSION]

static func package_schema_id() -> String:
	return schema_id(MANIFEST_TYPE)
