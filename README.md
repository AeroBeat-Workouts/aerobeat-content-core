# aerobeat-content-core

Shared AeroBeat content-domain types and structural validation helpers for the current imported-player package model: **song packages**, songs, charts, sets, shared chart-envelope types, and package reference validation.

## Architecture role

`aerobeat-content-core` is the lane owner for durable content-domain semantics. It defines the shared authored/imported record shapes and integrity rules that tooling and runtime consumers can both depend on while leaving gameplay execution, rendering, scoring, package import UX, and editor UX to other repos.

## Current package stance

The current canonical imported package contract is the **`song-package.yaml`-centered YAML package model** documented in `aerobeat-docs`.

Within that active default content model:

- imported playable content is organized as one **song package** per source song/root
- one song package may contain **multiple exact chart/set difficulty slices** for that song root
- the canonical package shape centers on `song-package.yaml`, `songs/`, `charts/`, and `sets/`
- **Set** is the package-local playable linker between one song and one chart
- package-local coaching is **not** part of the default imported-player contract
- package-local environments are **not** part of the default imported-player contract
- `workout.yaml` is retired; package-owned coaching and package-owned environments are not part of the default song-package contract

## Lane boundaries

This repo intentionally owns:

- shared authored/imported content record types and schema ids
- package/reference validation semantics shared across tooling
- Boxing and Flow chart/content vocabulary that belongs in durable authored content
- song-package/set/song/chart relationship rules
- narrow legacy-manifest fixture coverage needed while older fixture/test surfaces are retired

This repo intentionally does **not** own:

- editor UX or authoring workflow chrome
- CLI command parsing or tool orchestration
- gameplay scoring/runtime interpretation
- UI presentation or shell logic
- the full import/export pipeline for every product tool
- environment-package or coaching-extension runtime behavior

## Current repository contents

Current checked-in surfaces include:

- `data_types/` record classes for song packages, songs, charts, sets, plus legacy compatibility record types still used by some fixture/test paths
- `globals/` shared schema and vocabulary helpers
- `interfaces/` seams for chart loading, registry, and migration work
- `validators/` shared package/content validation helpers, including the canonical `song-package.yaml` bridge and legacy fallback paths
- `tests/` contract coverage for the imported song-package rules plus legacy compatibility fixtures
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

- valid canonical `song-package.yaml` fixture acceptance for the shared imported-player rules
- rejection of retired workout.yaml roots and stale root workout fields on canonical song-package fixtures
- rejection of stale per-set `environmentId` / `coachingOverlayId` fields on canonical song-package fixtures
- rejection of missing set/song/chart references
- legacy manifest fixture acceptance/rejection coverage where still needed for compatibility
- rejection of legacy Boxing strike labels such as `jab`, `cross`, `punch_left`, and `punch_right`
- rejection of stale portal fields on current Boxing/Flow chart beats
- validation of optional `aerobeat.boxing.prototype.v1` chart identity/provenance metadata, including canonical `row_family_balanced_height_v1` / `cut_family_source_height_v1` recipe IDs, Semantic/Spatial ruleset IDs, and source/recipe/ruleset/content hashes
- an explicit fail-closed cross-language boundary for the web successor's interval-bearing Boxing obstacles: this Godot/content-core generation still rejects any Boxing `end` with `invalid_boxing_end`, so web `normalized_obstacle_v2` Boxing charts must not be labeled Godot-compatible or imported here until a separately versioned Godot contract implements `sourceGeometry`/`gameplayGeometry`/`gridMask`/checkpoint parity
- validation of prototype Boxing event IDs, source lineage, explicit 8×6 punch subcells/directions, 100 ms straight qualification, crossed/adjacent guard targets, and 150 ms instantaneous defensive checkpoints
- validation of the approved Flow v1 authored object contract for `note`, `burst`, `bomb`, `obstacle`, and `arc`
- acceptance of optional lowercase `sha256:` `audio.contentHash` integrity metadata plus the shared song-audio preview fields `audio.previewFilePath` (packaged/local preview asset), `audio.previewUrl` (preserved provider/source preview URL truth), `audio.previewStartTime`, `audio.previewDuration`, and the converter-authored `audio.previewMode` playback decision (`song_file_clip` / `preview_file` / `preview_url`)
- preservation of the frozen first-pass Flow `burst` beat object fields inside that broader contract
- rejection of non-v1 gameplay modes such as Dance and Step
- validation of the approved BeatSaver regression candidate pool as small `song.package.yaml` fixtures that preserve exact BeatSaver IDs, group intent, difficulty role, and current Boxing/Flow chart event shape; these are synthetic contract slices and intentionally omit full BeatSaver map/audio/cover assets

## Repository status

This repo is the canonical home for shared content-lane contracts in the BeatSaver-powered AeroBeat direction. Keep the public surface centered on durable imported-content semantics and shared validation rules rather than quietly reintroducing retired workout/coaching/environment package assumptions.
