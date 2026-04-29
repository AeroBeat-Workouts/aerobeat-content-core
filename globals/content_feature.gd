class_name ContentFeature
extends RefCounted

const BOXING := "boxing"
const DANCE := "dance"
const STEP := "step"
const FLOW := "flow"

const ALL := [BOXING, DANCE, STEP, FLOW]

static func is_valid(feature: String) -> bool:
	return feature in ALL
