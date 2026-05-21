---
name: Remove playwright-root-error route
overview: Remove the `playwright-root-error` route and replace it with idiomatic Playwright test patterns that exercise the root error boundary without polluting the route tree.
todos:
  - id: delete-route
    content: Delete `src/routes/playwright-root-error.tsx`
    status: completed
  - id: regen-routes
    content: Regenerate `routeTree.gen.ts` to remove the PlaywrightRootErrorRoute entry
    status: completed
  - id: optional-test
    content: (Optional) Add a Playwright test for root error boundary using `page.route()` interception
    status: completed
isProject: false
---

# Remove `playwright-root-error` route

## Why it's safe to remove

The route at [`src/routes/playwright-root-error.tsx`](src/routes/playwright-root-error.tsx) is:

1. **Not referenced by any Playwright test** -- a search of `tests/` found zero references to `playwright-root-error`, `root-error`, or the `data-testid="root-error"` attribute.
2. **Dead in the current E2E setup** -- Playwright runs with `--mode e2e` (per [`playwright.config.ts`](playwright.config.ts)), but the route only throws in `"test"` mode. In all other modes it silently redirects to `/`. So it's not actually exercising anything today.
3. **Pollutes the production route tree** -- it registers a real route (`/playwright-root-error`) in `routeTree.gen.ts` and ships to production, where it just redirects.

## Better alternatives

There are two idiomatic ways to test the root `errorComponent` without a dedicated route:

### Option A: `page.route()` network interception (recommended)

Use Playwright's `page.route()` to intercept a loader request and force it to fail. This triggers the root error boundary on any real route without adding test-only routes to the app.

```typescript
// In a Playwright test file, e.g. tests/root-error.spec.ts
test("root error boundary renders on loader failure", async ({ page }) => {
  // Intercept the loader fetch for the home route and make it fail
  await page.route("**/api/**", (route) =>
    route.fulfill({ status: 500, body: "Simulated server error" })
  );
  await page.goto("/");
  await expect(page.getByTestId("root-error")).toBeVisible();
});
```

This is the most idiomatic Playwright approach -- it tests real user-facing behavior without any app-side test scaffolding.

### Option B: `page.evaluate()` to throw in the React tree

Use `page.evaluate()` after navigation to force an error inside the React component tree:

```typescript
test("root error boundary renders", async ({ page }) => {
  await page.goto("/");
  await page.evaluate(() => {
    throw new Error("E2E probe: root error boundary");
  });
  await expect(page.getByTestId("root-error")).toBeVisible();
});
```

This is simpler but less realistic since the error doesn't originate from a loader.

**Option A is recommended** because it simulates real failure conditions (server/loader errors) and doesn't require any test-specific code in the app.

## Implementation steps

1. **Delete** [`src/routes/playwright-root-error.tsx`](src/routes/playwright-root-error.tsx)
2. **Regenerate the route tree** -- run the TanStack Router code generation (or let the dev server do it) so `routeTree.gen.ts` drops the `PlaywrightRootErrorRoute` entry
3. **Optionally** add a proper Playwright test for the root error boundary using Option A above (only if you want test coverage for `RootError` -- right now there are zero tests for it)
4. **Check docs** -- no docs in `docs/` reference this route, so no doc updates needed
