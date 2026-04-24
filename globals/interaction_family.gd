class_name InteractionFamily
extends RefCounted

const GESTURE_2D := "gesture_2d"
const TRACKED_6DOF := "tracked_6dof"
const HYBRID := "hybrid"

const ALL := [GESTURE_2D, TRACKED_6DOF, HYBRID]

static func is_valid(interaction_family: String) -> bool:
	return interaction_family in ALL
