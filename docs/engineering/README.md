# Engineering Handbook

This is the implementation side of the brain. The ASO/marketing brain says *what to ship and why*; this handbook says *how to ship it without breaking the codebase's existing patterns*.

## Versions

The handbook is versioned. Each version is a frozen snapshot of:

- The agent role definition for Claude (Flutter engineer mode)
- The architecture canon (real conventions audited from the codebase)
- The per-feature spec template
- The definition of done
- The actual feature specs slated for that version

Why versioned: when conventions change (e.g., we migrate off GetX, or split the controller/logic naming inconsistency), the new spec format goes in `v2/` and old specs stay frozen in `v1/` for reference.

| Version | Status | Window | Folder |
| --- | --- | --- | --- |
| v1 | active | 2026-05-09 → ongoing | `v1/` |

## Active version

→ **[v1](v1/README.md)** — read this entry point first.

## When to bump the version

- A breaking change to the architecture canon (e.g., we switch state-management library)
- A breaking change to the feature spec template
- A change to the agent role or definition-of-done that would invalidate finished v1 specs

Cosmetic edits, new features added, or refinements that *don't* change the contract of completed specs stay in the current version.
