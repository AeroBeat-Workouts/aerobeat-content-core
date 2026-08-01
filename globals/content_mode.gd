class_name ContentMode
extends RefCounted

const BOXING := "boxing"
const FLOW := "flow"

const ALL := [BOXING, FLOW]

static func is_valid(mode: String) -> bool:
	return mode in ALL
