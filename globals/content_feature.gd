class_name ContentFeature
extends RefCounted

const BOXING := "boxing"
const FLOW := "flow"

const ALL := [BOXING, FLOW]

static func is_valid(feature: String) -> bool:
	return feature in ALL
