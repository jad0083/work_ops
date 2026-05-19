# work_ops

Inventory of useful stuff from work. Each top-level directory is one
self-contained item — a script, an IaC module, a recipe, notes, or
captures. No overarching architecture; no shared code across directories.

## Inventory

| Item | What it is |
|---|---|
| [`cloudsql-enhanced-backup/`](./cloudsql-enhanced-backup/) | Terraform module: Cloud SQL instance + Backup-and-DR vault, plan, and plan association. Targets Cloud SQL Enhanced Backups (GA 2025-12-17). |

## Convention

- One artifact per top-level directory.
- Each directory is self-contained — no shared utility code, no cross-directory imports. Copy/paste over premature abstraction.
