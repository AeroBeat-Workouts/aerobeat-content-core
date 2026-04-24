# aerobeat-content-core

Canonical AeroBeat authored-content contracts, including songs, routines, chart slices, workouts, shared chart-envelope types, and content loading or validation interfaces.

## Architecture role

`aerobeat-content-core` is the lane owner for durable authored-content contracts. It defines the reusable content model that feature repos consume, while keeping mode-specific runtime behavior out of the content lane.

## Day-one scaffold

This repo now carries the first contract-focused implementation slice described in `aerobeat-docs/docs/architecture/content-repo-shapes.md`:

- `interfaces/` for loader, registry, migration, and workout-resolution contracts
- `data_types/` for the core durable records and supporting ids/references/query shapes
- `validators/` for shared structural validation result types plus a minimal package validator
- `globals/` for stable schema ids, content modes, difficulty vocabulary, and interaction families
- `fixtures/` for valid and intentionally broken packages used by contract tests
- `tests/` for contract checks that exercise manifest validation, reference detection, workout-step validation, and workout-resolution semantics
- `.testbed/` for a tiny Godot headless project used to run the contract suite without pulling in editor UX or runtime visuals

## Workout contract slice

Workouts now treat `steps` as a first-class contract instead of an opaque blob.

- `data_types/workout_step.gd` defines authored workout-step requirements: `stepId` and `chartId` are required, with constrained optional references like `songId` and `routineId`
- `data_types/resolved_workout_step.gd` defines the canonical resolved shape: `stepId`, `chartId`, `songId`, `routineId`, `mode`, and `difficulty`
- `interfaces/workout_resolution.gd` documents that resolved workouts preserve authored step order and produce structurally legal step payloads using package-local content only
- `validators/content_package_validator.gd` now verifies workout-step legality from package content alone, including step required fields, unique `stepId`s per workout, chart existence, and optional `songId` / `routineId` consistency with the referenced chart

## Current scope

This scaffold is intentionally dependency-light and contract-focused. It is meant to answer:

- what fields make up valid content-lane records
- what basic shared enums/constants are canonical
- what package/reference checks are shared across tools and runtime
- what a tiny end-to-end content package looks like on day one

It intentionally does **not** own:

- editor UX
- CLI command parsing
- runtime rendering or scoring systems
- mode-specific semantic gameplay validation
- import/export workflow state

## Validation

Run the current headless contract suite with:

```bash
godot --headless --path .testbed --script res://../tests/run_contract_tests.gd
```

## Repository status

This repo is the canonical home for shared content-lane contracts in the six-core AeroBeat architecture. Keep the contract surface focused on durable content definitions and validation interfaces instead of drifting into gameplay logic or asset ownership.
