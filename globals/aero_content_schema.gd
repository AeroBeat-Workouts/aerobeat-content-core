class_name AeroContentSchema
extends RefCounted

const PACKAGE_MANIFEST_V1: String = "aerobeat.content.package_manifest.v1"
const SONG_V1: String = "aerobeat.content.song.v1"
const ROUTINE_V1: String = "aerobeat.content.routine.v1"
const CHART_V1: String = "aerobeat.content.chart.v1"
const WORKOUT_V1: String = "aerobeat.content.workout.v1"

const KNOWN_SCHEMAS := {
	PACKAGE_MANIFEST_V1: true,
	SONG_V1: true,
	ROUTINE_V1: true,
	CHART_V1: true,
	WORKOUT_V1: true,
}

static func is_known_schema(schema_id: String) -> bool:
	return KNOWN_SCHEMAS.has(schema_id)

static func is_known_record_schema(schema_id: String) -> bool:
	return schema_id in [SONG_V1, ROUTINE_V1, CHART_V1, WORKOUT_V1]
