class_name ContentDifficulty
extends RefCounted

const EASY := "easy"
const MEDIUM := "medium"
const HARD := "hard"
const PRO := "pro"

const ALL := [EASY, MEDIUM, HARD, PRO]

static func is_valid(difficulty: String) -> bool:
	return difficulty in ALL
