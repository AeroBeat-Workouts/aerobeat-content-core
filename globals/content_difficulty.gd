class_name ContentDifficulty
extends RefCounted

const EASY := "easy"
const MEDIUM := "medium"
const HARD := "hard"
const EXPERT := "expert"

static func all() -> Array[String]:
	return [EASY, MEDIUM, HARD, EXPERT]

static func is_valid(value: String) -> bool:
	return value in all()
