class_name ContentMode
extends RefCounted

const BOXING := "boxing"
const DANCE := "dance"
const STEP := "step"
const FLOW := "flow"

static func all() -> Array[String]:
	return [BOXING, DANCE, STEP, FLOW]

static func is_valid(value: String) -> bool:
	return value in all()
