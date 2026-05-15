# aerobeat-content-core

Shared AeroBeat content-domain types and structural validation helpers for the downscoped v1 package model: Songs, Charts, Sets, Workouts, Coach Configs, Environments, shared chart-envelope types, and package reference validation. Charts now validate the docs-aligned `beats` envelope directly, without requiring legacy `interactionFamily`.

## Architecture role

`aerobeat-content-core` owns the durable content-lane semantics shared by authoring tools and runtime consumers. It defines the core record shapes and shared integrity rules while leaving gameplay execution, rendering, scoring, package import UX, and editor UX to other repos.

## Canonical authored package contract

The current canonical authored package contract is the **workout.yaml-centered YAML package model** documented in `aerobeat-docs`.

At a high level, that contract is:

- one root `workout.yaml`
- `songs/`
- `charts/`
- `sets/`
- `coaches/`
- `environments/`

Key rules carried by this repo's shared types/validation semantics:

- official gameplay features are **boxing** and **flow**
- Boxing straight-punch chart types are `punch_left` / `punch_right`; `guard` is canonical wording
- `orthodox` / `southpaw` are valid authored Boxing stance semantics, even though they are not tracked input-event vocabulary
- Flow keeps `placement` = pass-through location and optional `direction` = follow-through guidance
- **dance** and **step** are not valid shared content-core feature values
- **Set** is the package-local composition linker between one song, one chart, one environment, and optional coaching overlay selection
- environment records officially accept `image_background`, `video_background`, `glb_environment`, and the controlled advanced `splat` type; for splats, AeroBeat officially recommends `.compressed.ply`, while GDGS compatibility support remains available for `.ply`, `.splat`, and `.sog` assets only
- **Workout** sequences ordered `setId` values
- coaching remains valid through workout-level coach-config content
- package-local gameplay `assets` and `assetSelections` are not part of the active v1 contract
- `routine` is not canonical truth in the active package model

For the source-of-truth package layout and authored-file examples, see the docs repo rather than this README's test fixtures.

## Important current limitation

This repo's checked-in Godot validator/test harness is **still not a full end-to-end validator for the canonical workout.yaml YAML package format**.

It now supports a **narrow canonical workout.yaml package bridge** in addition to the older transitional fixture path:

- **Canonical bridge:** loads one root `workout.yaml` plus `songs/`, `charts/`, `sets/`, `coaches/`, and `environments/` YAML records, then normalizes that package graph onto the shared content-core structural/reference checks
- **Transitional fixture layer:** `manifest.json` plus JSON record files referenced by that manifest

That means the repo can now truthfully validate the canonical YAML path for shared concerns such as ids, set/workout/environment linking, coach overlay references, and environment-type acceptance including `splat`. For `splat` environments specifically, the shared contract now reflects the current format policy: `.compressed.ply` is the official recommended AeroBeat authored path, while `.ply`, `.splat`, and `.sog` remain compatibility-supported through GDGS. It does **not** yet claim a total workout-package validator rewrite: YAML parsing/normalization is intentionally narrow and exists to bridge the canonical package shape onto the existing shared contract checks rather than replacing the entire transitional harness.

## Repository scope

This repo intentionally stays contract-focused. It answers:

- which shared record fields are structurally required
- which shared enums and schema ids are canonical
- which package/reference checks are shared across tooling
- what the set-centered content relationships mean

It intentionally does **not** own:

- editor UX
- CLI command parsing
- runtime rendering or scoring systems
- the full workout-package import/export pipeline
- YAML parsing/authoring UX for the canonical docs contract
- mode-specific semantic gameplay validation beyond shared structure
- internal product asset catalogs or package-local gameplay asset subsets

## Validation

Run the headless contract suite with:

```bash
godot --headless --path .testbed --script res://../tests/run_contract_tests.gd
```

Current suite coverage:

- valid canonical `workout.yaml` fixture acceptance for the shared set-centered rules, including `splat` environments using the recommended `.compressed.ply` path and set/environment linking
- valid transitional legacy-manifest fixture acceptance for the shared set-centered rules
- environment-type and splat resource-format contract coverage, including the recommended `.compressed.ply` path plus compatibility acceptance for `.ply`, `.splat`, and `.sog`, while rejecting unsupported formats such as `.spz`
- rejection of legacy Boxing punch labels such as `jab`, `cross`, `jab_left`, and `cross_right`
- acceptance of Boxing stance labels as authored chart semantics
- preservation of Flow `placement` vs `direction` chart-field semantics
- rejection of missing set/song references
- rejection of forbidden legacy manifest fields such as `routines`, `assets`, and `assetSelections`
- rejection of non-v1 gameplay features such as `dance` and `step`
- workout sequencing and workout-resolution semantics based on `setId`
- song timing structural validation

## Repository status

Status today:

- **shared record semantics:** aligned with the downscoped set-centered v1 model
- **canonical authored-package docs:** live in `aerobeat-docs` and are workout.yaml/YAML-centered
- **repo-local validator harness:** now split between a narrow canonical workout.yaml YAML bridge and the older legacy `manifest.json`/JSON-fixture compatibility path

The next meaningful validator step, when intentionally scoped, is broadening this bridge into a more complete workout-package YAML validator rather than silently pretending the bridge already replaces the full import/export toolchain.
