class_name ContentValidationResult
extends RefCounted

const ContentValidationIssue = preload("res://../validators/content_validation_issue.gd")

var issues: Array[ContentValidationIssue] = []

func add_issue(issue: ContentValidationIssue) -> void:
	issues.append(issue)

func is_valid() -> bool:
	for issue in issues:
		if issue.severity == ContentValidationIssue.SEVERITY_ERROR:
			return false
	return true

func error_count() -> int:
	var count := 0
	for issue in issues:
		if issue.severity == ContentValidationIssue.SEVERITY_ERROR:
			count += 1
	return count

func to_dict() -> Dictionary:
	var serialized: Array[Dictionary] = []
	for issue in issues:
		serialized.append(issue.to_dict())
	return {
		"valid": is_valid(),
		"issues": serialized,
	}
