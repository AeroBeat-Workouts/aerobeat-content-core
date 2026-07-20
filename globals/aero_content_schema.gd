class_name AeroContentSchema
extends RefCounted

const PACKAGE_MANIFEST_V1: String = "aerobeat.content.package_manifest.v1"
const SONG_PACKAGE_V1: String = "aerobeat.content.song_package.v1"
const SONG_V1: String = "aerobeat.content.song.v1"
const CHART_V1: String = "aerobeat.content.chart.v1"
const SET_V1: String = "aerobeat.content.set.v1"
const WORKOUT_V1: String = "aerobeat.content.workout.v1"
const COACH_CONFIG_V1: String = "aerobeat.content.coach_config.v1"
const ENVIRONMENT_V1: String = "aerobeat.content.environment.v1"

const KNOWN_SCHEMAS := {
	PACKAGE_MANIFEST_V1: true,
	SONG_PACKAGE_V1: true,
	SONG_V1: true,
	CHART_V1: true,
	SET_V1: true,
	WORKOUT_V1: true,
	COACH_CONFIG_V1: true,
	ENVIRONMENT_V1: true,
}

const RECORD_SCHEMAS := {
	SONG_PACKAGE_V1: true,
	SONG_V1: true,
	CHART_V1: true,
	SET_V1: true,
	WORKOUT_V1: true,
	COACH_CONFIG_V1: true,
	ENVIRONMENT_V1: true,
}

static func is_known_schema(schema_id: String) -> bool:
	return KNOWN_SCHEMAS.has(schema_id)

static func is_known_record_schema(schema_id: String) -> bool:
	return RECORD_SCHEMAS.has(schema_id)
