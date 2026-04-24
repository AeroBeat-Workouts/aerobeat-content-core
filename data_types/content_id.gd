class_name ContentId
extends RefCounted

const SONG := "song"
const ROUTINE := "routine"
const CHART := "chart"
const WORKOUT := "workout"
const PACKAGE := "package"

static func is_valid_uid(value: Variant) -> bool:
	if not (value is String):
		return false
	var uid := String(value)
	if uid.length() < 3:
		return false
	for i in uid.length():
		var char_code: int = uid.unicode_at(i)
		var char_text := uid.substr(i, 1)
		var is_lower := char_code >= 97 and char_code <= 122
		var is_digit := char_code >= 48 and char_code <= 57
		var is_allowed_symbol := char_text == "-" or char_text == "_"
		if not (is_lower or is_digit or is_allowed_symbol):
			return false
	return true
