---
name: TanStack Form Refactor
overview: Refactor the workspace creation form from manual controlled inputs to TanStack Form, eliminating the FormData/state dual-source workaround, and update integration tests to work reliably with the new form.
todos:
  - id: refactor-form
    content: Refactor new.tsx from useState to useForm from @tanstack/react-form, wire both fields via form.Field, use form.Subscribe for submit button state
    status: completed
  - id: cleanup-debug
    content: Remove debug divs (hello, isCreating, name) and unused state/imports
    status: completed
  - id: run-tests
    content: Run workspace-new.spec.ts with Playwright to verify fill() works with TanStack Form
    status: in_progress
  - id: fix-test-issues
    content: Fix any remaining test reliability issues (networkidle, hardcoded URLs)
    status: pending
  - id: typecheck
    content: Run pnpm typecheck to verify no type errors
    status: pending
isProject: false
---

# TanStack Form Refactor for Workspace New Page

## Problem

The current form in [new.tsx](apps/org-next/src/routes/_authed/workspace/new.tsx) uses manual `useState` for each field plus a `FormData` fallback in the submit handler. This dual-source approach was added to work around Playwright's `fill()` not syncing with React controlled state. The tests in [workspace-new.spec.ts](apps/org-next/tests/workspace-new.spec.ts) are still unreliable.

TanStack Form manages its own internal store and wires `onChange` handlers that call `field.handleChange(e.target.value)`. When Playwright's `fill()` dispatches native input events, these handlers fire and update the form store -- no need for a FormData fallback.

## Idiomatic TanStack Form v1 Patterns (from latest docs)

Key patterns to follow, sourced from the [official TanStack Form v1 docs](https://tanstack.com/form/latest/docs/framework/react/guides/basic-concepts) and the [Simple Example](https://tanstack.com/form/latest/docs/framework/react/examples/simple):

- **Form submission**: Always call `e.preventDefault()` and `e.stopPropagation()` in the form's `onSubmit`, then delegate to `form.handleSubmit()`:
  ```typescript
  onSubmit={(e) => {
    e.preventDefault()
    e.stopPropagation()
    form.handleSubmit()
  }}
  ```
- **Field wiring**: Every input must wire three things -- `value`, `onBlur`, and `onChange`:
  ```typescript
  value={field.state.value}
  onBlur={field.handleBlur}
  onChange={(e) => field.handleChange(e.target.value)}
  ```
- **HTML `name` and `id` from field**: Use `field.name` for both the input `name` and `id` attributes (enables native form semantics and label `htmlFor`). We will override `id` to keep `workspace-name` for test compatibility.
- **`form.Subscribe` with selector**: Use `selector` to subscribe to only the state you need (avoids unnecessary re-renders):
  ```typescript
  <form.Subscribe
    selector={(state) => [state.canSubmit, state.isSubmitting]}
    children={([canSubmit, isSubmitting]) => (
      <button type="submit" disabled={!canSubmit}>
        {isSubmitting ? '...' : 'Submit'}
      </button>
    )}
  />
  ```
- **`canSubmit`**: TanStack Form provides `state.canSubmit` which reflects validation state automatically -- use this instead of manual `!name.trim()` checks when validators are configured.
- **`useStore` always needs a selector**: If accessing form store reactively outside of `form.Subscribe`, always pass a selector to `useStore(form.store, (state) => ...)` -- omitting it causes unnecessary re-renders.
- **Validators on fields**: Validation functions return `undefined` for valid, or an error string. Supports `onChange`, `onBlur`, `onSubmit`, and async variants.
- **Async `onSubmit`**: The `onSubmit` handler can be `async` -- TanStack Form automatically sets `isSubmitting` to `true` for the duration of the promise.

## Approach

Use `useForm` from `@tanstack/react-form` directly (already in [package.json](apps/org-next/package.json) as `^1.0.0`). This follows the same pattern as [public-pages/$slug.$token.tsx](apps/public-pages/src/routes/lead/$slug.$token.tsx). We will NOT add `@workspace/form` -- the shared package is heavy (30+ field types) and unnecessary for a 2-field form.

## Key design decisions

- **Both fields in the form**: `name` (string) and `workspaceType` (TenantType) both live in TanStack Form's `defaultValues`, giving the form a single source of truth
- **Workspace type buttons**: Keep the existing custom button UI but wire `onClick` to `field.handleChange(option.value)` via a `form.Field` render prop
- **Validation**: Use `validators.onSubmit` on the name field (`!value.trim() ? "Name is required" : undefined`). This feeds into `canSubmit` automatically
- **Submit button**: Use `form.Subscribe` with `selector={(state) => [state.canSubmit, state.isSubmitting]}` and disable with `!canSubmit` (the idiomatic pattern). This replaces the manual `!name.trim()` check
- **Submit handler**: Use `form.handleSubmit()` which runs validation, then calls the async `onSubmit({ value })`. TanStack Form manages `isSubmitting` automatically during the async operation
- **Error state**: Keep `formError` as separate `useState` since it's a server error, not a field validation error
- **Clean up**: Remove the debug divs (`hello`, `JSON.stringify(isCreating)`, `{name}`) on lines 179-181

## Step-by-step

### Step 1: Refactor `new.tsx` to use TanStack Form

**Imports**: Replace `useState` with `useForm`:
```typescript
import { useForm } from "@tanstack/react-form";
```
Keep `useState` only for `formError`.

**Form instance**: Replace the three `useState` calls with one `useForm`:
```typescript
const [formError, setFormError] = useState<string | null>(null);

const form = useForm({
  defaultValues: {
    name: "",
    workspaceType: "org" as TenantType,
  },
  onSubmit: async ({ value }) => {
    setFormError(null);
    try {
      await createTenantFn({
        data: { name: value.name.trim(), tenantType: value.workspaceType },
      });
      await router.invalidate();
      await navigate({ to: "/" });
    } catch {
      setFormError("Could not create your workspace. Please try again.");
    }
  },
});
```

**Form element** -- follow the idiomatic `preventDefault` + `stopPropagation` + `handleSubmit` pattern:
```typescript
<form
  className="space-y-5"
  onSubmit={(e) => {
    e.preventDefault();
    e.stopPropagation();
    form.handleSubmit();
  }}
>
```

**Name input** via `form.Field` with `onSubmit` validator:
```typescript
<form.Field
  name="name"
  validators={{
    onSubmit: ({ value }) =>
      !value.trim() ? "Name is required" : undefined,
  }}
  children={(field) => (
    <Field>
      <FieldLabel htmlFor="workspace-name">Workspace name</FieldLabel>
      <Input
        autoComplete="organization"
        className="h-10"
        id="workspace-name"
        name={field.name}
        onBlur={field.handleBlur}
        onChange={(e) => field.handleChange(e.target.value)}
        placeholder="e.g. Hope Foundation"
        value={field.state.value}
      />
    </Field>
  )}
/>
```

**Workspace type** via `form.Field`:
```typescript
<form.Field
  name="workspaceType"
  children={(field) => (
    <Field>
      <FieldLabel>Workspace type</FieldLabel>
      <div className="flex flex-col gap-2">
        {workspaceTypeOptions.map((option) => (
          <button
            className={cn(
              "rounded-xl border-2 p-3.5 text-left transition-colors",
              field.state.value === option.value
                ? "border-secondary-500 bg-secondary-50"
                : "border-border bg-card hover:border-muted-foreground/30",
            )}
            key={option.value}
            type="button"
            onClick={() => field.handleChange(option.value)}
          >
            {/* ...existing label + description markup */}
          </button>
        ))}
      </div>
    </Field>
  )}
/>
```

**Submit button** via `form.Subscribe` with `canSubmit` + `isSubmitting`:
```typescript
<form.Subscribe
  selector={(state) => [state.canSubmit, state.isSubmitting]}
  children={([canSubmit, isSubmitting]) => (
    <Button
      className="w-full"
      disabled={!canSubmit || isSubmitting}
      type="submit"
    >
      {isSubmitting ? "Creating workspace..." : "Create workspace"}
    </Button>
  )}
/>
```

**Remove**: `method="post"` from form, all debug divs, the `handleSubmit` function, unused `useState` for `name`/`workspaceType`/`isCreating`, the `FormData` logic.

### Step 2: Run the integration tests

Run the existing tests to verify the form works with Playwright `fill()`:

```bash
pnpm exec playwright test tests/workspace-new.spec.ts --headed
```

The tests use `page.locator("#workspace-name").fill(value)` which should now trigger TanStack Form's `onChange` -> `field.handleChange` pipeline. Since TanStack Form's state is updated via the wired `onChange` handler (not a separate `useState`), the form store stays in sync with the DOM value.

### Step 3: Fix any test issues

If tests still fail, likely adjustments:
- The `gotoWorkspaceNew` helper uses `networkidle` which may need replacing with an explicit heading wait
- The URL assertion uses hard-coded `localhost:3210` -- may need updating to `"/"`
- Confirm the submit button becomes enabled after `fill()` by asserting `toBeEnabled()` before clicking

### Step 4: Typecheck

Run `pnpm typecheck` from `apps/org-next` to verify no type errors were introduced.
