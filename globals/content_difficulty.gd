class_name ContentDifficulty
extends RefCounted

const EASY := "Easy"
const NORMAL := "Normal"
const HARD := "Hard"
const EXPERT := "Expert"
const EXPERT_PLUS := "ExpertPlus"

const ALL := [EASY, NORMAL, HARD, EXPERT, EXPERT_PLUS]

static func is_valid(difficulty: String) -> bool:
	return difficulty in ALL
