extends RefCounted

const Song = preload("res://addons/aerobeat-content-core/data_types/song.gd")
const ContentPackageValidator = preload("res://addons/aerobeat-content-core/validators/content_package_validator.gd")

static func run() -> Dictionary:
	var validator := ContentPackageValidator.new()
	var valid_fixture_path := ProjectSettings.globalize_path("res://addons/aerobeat-content-core/fixtures/song_package_yaml_valid_splat_with_preview_audio")
	var valid_result := validator.validate_song_package_yaml_package(valid_fixture_path)
	var loaded := validator._load_song_package_yaml_package_data(valid_fixture_path, "song-package.yaml")
	var loaded_songs: Array = loaded.get("package_data", {}).get("songs", [])
	var normalized_audio: Dictionary = {}
	if not loaded_songs.is_empty():
		normalized_audio = Dictionary(loaded_songs[0].get("data", {}).get("audio", {}))
	var invalid_codes := _sorted_codes(Song.validate_audio_shape({
		"audio": {
			"previewFilePath": 123,
			"previewUrl": "",
			"previewStartTime": "12.5",
			"previewDuration": false,
			"previewMode": "derive_it_later",
		}
	}))
	var passed: bool = (
		valid_result.is_valid()
		and normalized_audio.get("previewFilePath", "") == "media/audio/splat-demo-preview.ogg"
		and normalized_audio.get("previewResourcePath", "") == "media/audio/splat-demo-preview.ogg"
		and normalized_audio.get("previewUrl", "") == "https://cdn.example.invalid/beatsaver/splat-demo-preview.mp3"
		and is_equal_approx(float(normalized_audio.get("previewStartTime", -1.0)), 12.5)
		and is_equal_approx(float(normalized_audio.get("previewDuration", -1.0)), 3.25)
		and normalized_audio.get("previewMode", "") == "preview_file"
		and invalid_codes == [
			"song_audio_field_invalid_type",
			"song_audio_field_invalid_type",
			"song_audio_field_invalid_type",
			"song_audio_field_invalid_type",
			"song_audio_invalid_preview_mode",
		]
	)
	return {
		"name": "song_preview_audio_contract",
		"passed": passed,
		"details": {
			"valid": valid_result.to_dict(),
			"normalizedAudio": normalized_audio,
			"invalidCodes": invalid_codes,
		},
	}

static func _sorted_codes(issues: Array) -> Array[String]:
	var codes: Array[String] = []
	for issue in issues:
		codes.append(String(issue.get("code", "")))
	codes.sort()
	return codes
