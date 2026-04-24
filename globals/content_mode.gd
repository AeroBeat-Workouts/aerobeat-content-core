class_name ContentMode
extends RefCounted

const BOXING := "boxing"
const DANCE := "dance"
const STEP := "step"
const FLOW := "flow"

const ALL := [BOXING, DANCE, STEP, FLOW]

static func is_valid(mode: String) -> bool:
	return mode in ALL
