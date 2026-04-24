extends RefCounted

const ContentPackageManifest = preload("res://../data_types/content_package_manifest.gd")
const AeroContentSchema = preload("res://../globals/aero_content_schema.gd")

static func run() -> Dictionary:
	var manifest := ContentPackageManifest.new({
		"package_id": "package.minimal_boxing",
		"schema": AeroContentSchema.package_schema_id(),
		"version": AeroContentSchema.VERSION,
		"songs": ["song.demo"],
		"routines": ["routine.demo_boxing"],
		"charts": ["chart.demo_boxing.medium"],
		"workouts": ["workout.demo"],
	})
	assert(manifest.package_id == "package.minimal_boxing")
	assert(manifest.schema == "aerobeat.content.content_package_manifest.v1")
	assert(manifest.workouts.size() == 1)
	return {
		"name": "test_content_manifest_contract",
		"passed": true,
		"details": manifest.to_dict(),
	}
