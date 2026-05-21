---
name: Fix jest-dom type errors
overview: The `@testing-library/jest-dom` matchers (toBeVisible, toHaveClass, etc.) are missing their TypeScript type declarations in the org app. The package is imported at runtime via the vitest setup file but its type augmentation for vitest's `Assertion` interface is never seen by TypeScript during compilation.
todos:
  - id: add-dep
    content: Add @testing-library/jest-dom as peer dep in test-utils and devDep in org, run pnpm install
    status: completed
  - id: add-ref
    content: Add `/// <reference types="@testing-library/jest-dom/vitest" />` to apps/org/src/test-utils.tsx
    status: completed
  - id: verify
    content: Run tsc --noEmit in apps/org to confirm all 9 errors are gone
    status: completed
isProject: false
---

# Fix jest-dom type errors in org app

## Problem

All test files in `apps/org` using jest-dom matchers (`toBeVisible`, `toHaveClass`, etc.) fail typechecking with:

```
Property 'toHaveClass' does not exist on type 'Assertion<HTMLElement>'
```

9 errors across 2 test files: `page-actions.test.tsx` and `page-header.test.tsx`.

## Root Cause

The type augmentation chain is broken:

1. **Runtime**: works fine -- [vitest.config.ts](apps/org/vitest.config.ts) lists `@workspace/test-utils/vitest` as a setup file, which imports `@testing-library/jest-dom/vitest` and calls `expect.extend(matchers)` at runtime.

2. **TypeScript**: broken -- The `@testing-library/jest-dom/vitest` entry exports a `declare module 'vitest' { interface Assertion<T> extends TestingLibraryMatchers ... }` augmentation, but TypeScript never encounters this file during compilation because:
   - `@testing-library/jest-dom` is **not declared as a dependency** in any `package.json` (not in [test-utils](packages/test-utils/package.json), not in [org](apps/org/package.json))
   - TypeScript doesn't follow vitest `setupFiles` -- it only sees files included via tsconfig or import chains
   - No `.d.ts` reference directive brings the augmentation into scope

## Fix (2 changes)

### 1. Declare the missing dependency in `packages/test-utils/package.json`

Add `@testing-library/jest-dom` as a peer dependency in [packages/test-utils/package.json](packages/test-utils/package.json), since `src/vitest.ts` imports from it:

```json
"peerDependencies": {
  "@testing-library/jest-dom": "^6.0.0",
  ...existing peers...
}
```

And add it as a devDependency in [apps/org/package.json](apps/org/package.json):

```json
"devDependencies": {
  "@testing-library/jest-dom": "^6.0.0",
  ...existing devDeps...
}
```

Then run `pnpm install` to resolve it.

### 2. Add a type reference directive in the org app

Add a triple-slash reference at the top of [apps/org/src/test-utils.tsx](apps/org/src/test-utils.tsx) (which is already a vitest setup file per `vitest.config.ts`):

```typescript
/// <reference types="@testing-library/jest-dom/vitest" />
```

This tells TypeScript to include the `@testing-library/jest-dom/vitest` type augmentation in the compilation, which adds `toBeVisible`, `toHaveClass`, and all other jest-dom matchers to vitest's `Assertion` interface.

## Verification

Run `cd apps/org && npx tsc --noEmit` -- the 9 errors should be resolved.
