# aerobeat-content-core

Shared AeroBeat content-domain types and structural validation helpers for the downscoped v1 package model: Songs, Charts, Sets, Workouts, Coach Configs, Environments, shared chart-envelope types, and package reference validation.

## Architecture role

`aerobeat-content-core` is the lane owner for durable content-domain semantics. It defines the shared authored-record shapes and integrity rules that tooling and runtime consumers can both depend on while leaving gameplay execution, rendering, scoring, package import UX, and editor UX to other repos.

## V1 scope stance

The current canonical authored package contract is the **workout.yaml-centered YAML package model** documented in `aerobeat-docs`.

Within that active v1 content model:

- official gameplay features are **boxing** and **flow**
- the canonical package shape centers on `workout.yaml`, `songs/`, `charts/`, `sets/`, `coaches/`, and `environments/`
- **Set** is the package-local composition linker between one song, one chart, one environment, and optional coaching overlay selection
- environment records remain valid authored content
- package-local gameplay `assets` and `assetSelections` are not part of the active v1 contract
- `routine`, Dance, and Step are not canonical truth in the current shared content model

## Lane boundaries

This repo intentionally owns:

- shared authored content record types and schema ids
- package/reference validation semantics shared across tooling
- Boxing and Flow chart/content vocabulary that belongs in durable authored content
- set/workout/environment relationship rules
- shared environment-type acceptance and related content validation boundaries

This repo intentionally does **not** own:

- editor UX or authoring workflow chrome
- CLI command parsing or tool orchestration
- gameplay scoring/runtime interpretation
- UI presentation or shell logic
- the full import/export pipeline for every product tool

## Current repository contents

Current checked-in surfaces include:

- `data_types/` record classes for songs, charts, sets, workouts, environments, coach configs, and related content entities
- `globals/` shared schema and vocabulary helpers
- `interfaces/` seams for chart loading, registry, migration, and workout resolution
- `validators/` shared package/content validation helpers, including the narrow YAML bridge
- `tests/` contract coverage for the set-centered v1 package rules and legacy compatibility fixtures
- hidden `.testbed/` Godot project wiring used to run the contract suite

## Intended consumers

Authoring tools, package validators, import/export flows, runtime content-resolution layers, and assembly repos should depend on this package when they need stable shared content contracts rather than re-teaching the same authored-schema rules independently.

## Development and validation

This repo includes a repo-local contract harness.

Run the headless suite with:

```bash
godot --headless --path .testbed --script res://../tests/run_contract_tests.gd
```

Current suite coverage includes:

- valid canonical `workout.yaml` fixture acceptance for the shared set-centered rules
- valid transitional legacy-manifest fixture acceptance
- environment-type and `splat` resource-format contract coverage
- rejection of legacy Boxing punch labels such as `jab` and `cross`
- preservation of Flow `placement` vs `direction` chart-field semantics
- rejection of missing set/song references and forbidden legacy manifest fields
- rejection of non-v1 gameplay features such as Dance and Step

## Repository status

This repo is the canonical home for shared Content-lane contracts in the downscoped AeroBeat v1 architecture. Keep the public surface centered on durable authored-content semantics and shared validation rules rather than quietly absorbing tool UX, gameplay runtime behavior, or removed package-local asset concepts.
