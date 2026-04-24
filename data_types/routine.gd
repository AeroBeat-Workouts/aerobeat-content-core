class_name Routine
extends RefCounted

var id: String
var song_id: String
var mode: String
var title: String
var tags: Array[String]

func _init(data: Dictionary = {}) -> void:
	id = data.get("id", "")
	song_id = data.get("song_id", "")
	mode = data.get("mode", "")
	title = data.get("title", "")
	tags = Array(data.get("tags", []), TYPE_STRING, "", null)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"song_id": song_id,
		"mode": mode,
		"title": title,
		"tags": tags,
	}
