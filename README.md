# aerobeat-content-core

Canonical AeroBeat authored-content contracts, including songs, routines, chart variants, workouts, shared chart-envelope types, and content loading or validation interfaces.

## Architecture role

`aerobeat-content-core` is the lane owner for durable authored-content contracts. It defines the reusable content model that feature repos consume, while keeping mode-specific runtime behavior out of the content lane.

## Intended consumers

Feature repos, tooling, and assemblies should depend on this repo when they need shared authored-content types, loading contracts, or validation surfaces.

## Repository status

This repo is the canonical home for shared content-lane contracts in the six-core AeroBeat architecture. Keep the contract surface focused on durable content definitions and validation interfaces instead of drifting into gameplay logic or asset ownership.
