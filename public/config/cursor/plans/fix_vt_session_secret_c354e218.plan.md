---
name: fix vt session secret
overview: Fix the virtual-terminal dev auth failure by making `SESSION_SECRET` a first-class validated server env var, then add a focused regression guard around the env/session contract.
todos:
  - id: declare-session-secret
    content: Declare `SESSION_SECRET` in the virtual-terminal t3 env schema with a 32-character minimum
    status: pending
  - id: add-regression-test
    content: Add a targeted test that guards the virtual-terminal env/session secret contract
    status: pending
  - id: validate-vt
    content: Run focused virtual-terminal validation after implementation
    status: pending
isProject: false
---

# Fix Virtual Terminal Session Secret

The likely root cause is in [`apps/virtual-terminal/src/env.ts`](apps/virtual-terminal/src/env.ts): `SESSION_SECRET` is documented and used by session/auth helpers, but it is not declared in the t3 env schema. That means calls like this can hand an empty/undefined password to TanStack `useSession`, which surfaces as `empty password`:

```ts
return useSession<{ authToken?: string }>({
  password: env.SESSION_SECRET,
  name: "authToken",
  // ...
});
```

Plan:

1. Update [`apps/virtual-terminal/src/env.ts`](apps/virtual-terminal/src/env.ts) to declare `SESSION_SECRET` as a server env var with `z.string().min(32)`, matching [`apps/virtual-terminal/docs/README.md`](apps/virtual-terminal/docs/README.md) and `.env.template`.
2. Add a focused regression test for the virtual-terminal env contract so `SESSION_SECRET` cannot disappear from validation again.
3. Re-check docs after the code change. The existing virtual-terminal docs already say `SESSION_SECRET` is required, so I expect no docs edit unless the implementation reveals a more precise note is useful.
4. Validate with the narrow virtual-terminal test/typecheck first, then use the repo’s preferred validation path if the change is accepted and time permits.