# aerobeat-content-core

Canonical AeroBeat authored-content contracts, fixtures, and validation surfaces.

## Architecture role

`aerobeat-content-core` is the lane owner for durable authored-content contracts. It defines the reusable content model that feature repos, tools, tests, and packaging flows consume, while keeping mode-specific runtime behavior and authoring UX out of the content lane.

## Day-one scaffold

This repository now provides a minimal but real contract-first scaffold organized around the approved content repo shape:

- `interfaces/` defines chart loading, registry lookup, migration, and workout-resolution contracts.
- `data_types/` defines stable record types for songs, routines, chart variants, workouts, manifests, ids, references, and queries.
- `validators/` contains shared validation report types plus a package validator that can sanity-check the included fixtures.
- `globals/` holds schema ids and shared vocabulary such as content modes, difficulties, and interaction families.
- `fixtures/` provides one valid package and one intentionally invalid package for regression coverage.
- `tests/` documents the intended contract behavior for manifests, references, and workout resolution.

## Repository boundary

This repo should own:

- canonical authored-content records
- schema/version ids and package manifest contracts
- reference/query primitives and shared validation interfaces
- contract fixtures and tests that prove the shared content language

This repo should not own:

- gameplay scoring or runtime spawning logic
- feature-local semantic validation
- editor UX, CLI presentation, or hosted content services
- renderers, scenes, or other presentation-heavy runtime systems

## Intended consumers

Feature repos, tooling, and assemblies should depend on this repo when they need shared authored-content types, validation surfaces, or package fixtures that define what valid AeroBeat content looks like.
