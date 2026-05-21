---
name: Fallow unlisted deps cause
overview: The 12 "unlisted dependencies" are false positives caused by a blanket `**/*.json` entry in root `.fallowrc.json` ignore patterns, not by fallow missing pnpm workspaces or `@workspace/*` packages.
todos:
  - id: narrow-json-ignore
    content: Remove or narrow `**/*.json` in root `.fallowrc.json` so workspace `package.json` files participate in unlisted-deps checks
    status: pending
  - id: verify-fallow
    content: Run `pnpm run fallow` from repo root and confirm unlisted-deps are gone
    status: pending
isProject: false
---

# Why fallow reports 12 unlisted dependencies

## Short answer

Fallow **does** see your workspace layout (it discovers 19 workspaces from [`pnpm-workspace.yaml`](pnpm-workspace.yaml) and resolves cross-package imports). The `publicPackages` field in [`.fallowrc.json`](.fallowrc.json) is for a **different** rule: it tells fallow that exports from those `@workspace/*` **libraries** are intentional public API (unused-export suppression), not for treating npm packages as "listed."

The unlisted-deps rule means: "this import’s package name is not declared in the **`package.json` that owns this file**." Your imports under `apps/org-next` **are** declared in [`apps/org-next/package.json`](apps/org-next/package.json) (including `catalog:` entries). Fallow still reports them because it is **not** using that file when checking.

## Root cause

[`.fallowrc.json`](.fallowrc.json) includes this pattern in `ignorePatterns`:

```json
"**/*.json"
```

That excludes **every** JSON file from fallow’s project model, including **all `package.json` files**. With those manifests excluded, dependency ownership for files like `apps/org-next/src/...` does not resolve to [`apps/org-next/package.json`](apps/org-next/package.json). The check then effectively compares imports against a parent manifest that does **not** list org-next’s direct dependencies (e.g. the root [`package.json`](package.json)), so fallow reports them as "unlisted."

**Evidence:** Running `fallow dead-code` with the same config but **without** the `**/*.json` ignore reports `No issues found` for unlisted dependencies, while the current config reports exactly 12 (the packages org-next imports but the root package does not declare): e.g. `lucide-react`, `zod`, `@tanstack/react-query`, `rollbar`, etc.

```mermaid
flowchart LR
  subgraph bad [With "**/*.json" ignored]
    Src[apps/org-next/src/foo.tsx]
    Wrong[Root or incomplete manifest]
    Src --> Wrong
    Wrong -->|"missing dep names"| Unlisted[Unlisted deps]
  end
  subgraph good [package.json not ignored]
    Src2[apps/org-next/src/foo.tsx]
    Right[apps/org-next/package.json]
    Src2 --> Right
    Right -->|"deps match imports"| OK[No unlisted false positives]
  end
```

## Fix (when you implement)

- **Preferred:** Remove the blanket `**/*.json` from `ignorePatterns`, or replace it with **narrower** globs if the goal was to skip specific JSON (e.g. generated assets, locales), without ignoring `package.json` files.
- **Not recommended as the real fix:** Adding all 12 names to `ignoreDependencies` — that only masks the misconfiguration.

After narrowing/removing the JSON ignore, re-run `pnpm run fallow` from the root; unlisted-deps for org-next should clear without changing real dependencies.

## Docs note

[`publicPackages`](https://docs.fallow.tools/configuration/overview#publicpackages) ≠ listed dependencies. For suppressing unlisted false positives, the docs point to [`ignoreDependencies`](https://docs.fallow.tools/configuration/overview#ignoredependencies) only when a package is truly implicit (e.g. runtime-provided); here the correct fix is manifest visibility, not `ignoreDependencies`.
