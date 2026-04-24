class_name InteractionFamily
extends RefCounted

const GESTURE_2D := "gesture_2d"
const TRACKED_6DOF := "tracked_6dof"
const HYBRID := "hybrid"

static func all() -> Array[String]:
	return [GESTURE_2D, TRACKED_6DOF, HYBRID]

static func is_valid(value: String) -> bool:
	return value in all()
