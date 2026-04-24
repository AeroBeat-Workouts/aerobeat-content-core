class_name ContentPackageManifest
extends RefCounted

const AeroContentSchema = preload("res://../globals/aero_content_schema.gd")

var package_id: String
var schema: String
var version: int
var songs: Array[String]
var routines: Array[String]
var charts: Array[String]
var workouts: Array[String]

func _init(data: Dictionary = {}) -> void:
	package_id = data.get("package_id", "")
	schema = data.get("schema", AeroContentSchema.package_schema_id())
	version = int(data.get("version", AeroContentSchema.VERSION))
	songs = Array(data.get("songs", []), TYPE_STRING, "", null)
	routines = Array(data.get("routines", []), TYPE_STRING, "", null)
	charts = Array(data.get("charts", []), TYPE_STRING, "", null)
	workouts = Array(data.get("workouts", []), TYPE_STRING, "", null)

func to_dict() -> Dictionary:
	return {
		"package_id": package_id,
		"schema": schema,
		"version": version,
		"songs": songs,
		"routines": routines,
		"charts": charts,
		"workouts": workouts,
	}
