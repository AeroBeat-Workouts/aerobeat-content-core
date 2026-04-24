class_name ContentValidationIssue
extends RefCounted

const SEVERITY_ERROR := "error"
const SEVERITY_WARNING := "warning"

var severity: String
var code: String
var path: String
var message: String

func _init(p_severity: String = SEVERITY_ERROR, p_code: String = "", p_path: String = "", p_message: String = "") -> void:
	severity = p_severity
	code = p_code
	path = p_path
	message = p_message

func to_dict() -> Dictionary:
	return {
		"severity": severity,
		"code": code,
		"path": path,
		"message": message,
	}
