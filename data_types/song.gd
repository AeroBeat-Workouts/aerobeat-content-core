class_name Song
extends RefCounted

var id: String
var title: String
var artist: String
var bpm: float
var duration_ms: int
var audio_asset: String
var tags: Array[String]

func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	title = data.get("title", "")
	artist = data.get("artist", "")
	bpm = float(data.get("bpm", 0.0))
	duration_ms = int(data.get("duration_ms", 0))
	audio_asset = data.get("audio_asset", "")
	tags = Array(data.get("tags", []), TYPE_STRING, "", null)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"title": title,
		"artist": artist,
		"bpm": bpm,
		"duration_ms": duration_ms,
		"audio_asset": audio_asset,
		"tags": tags,
	}
