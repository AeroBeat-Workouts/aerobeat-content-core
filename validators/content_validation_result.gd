class_name ContentValidationResult
extends RefCounted

var issues: Array[Dictionary] = []

func add_issue(issue: Dictionary) -> void:
	issues.append(issue)

func merge(other: ContentValidationResult) -> void:
	for issue in other.issues:
		issues.append(issue)

func is_valid() -> bool:
	return issues.is_empty()

func error_count() -> int:
	return issues.size()

func to_dict() -> Dictionary:
	return {
		"valid": is_valid(),
		"issueCount": error_count(),
		"issues": issues,
	}
