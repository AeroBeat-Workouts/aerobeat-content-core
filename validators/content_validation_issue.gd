class_name ContentValidationIssue
extends RefCounted

const SEVERITY_ERROR := "error"
const SEVERITY_WARNING := "warning"

static func create(code: String, severity: String, message: String, path: String = "", reference: Dictionary = {}) -> Dictionary:
	return {
		"code": code,
		"severity": severity,
		"message": message,
		"path": path,
		"reference": reference,
	}
