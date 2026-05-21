---
name: t3-env detailed errors
overview: Add a custom `onValidationError` handler to `src/env.ts` so t3-env surfaces the specific variable name(s) and reason in the thrown error, instead of the generic "Invalid environment variables".
todos:
  - id: update-env
    content: Add custom onValidationError to apps/org-next/src/env.ts that formats each issue's path and message into the thrown error
    status: completed
  - id: verify
    content: Re-run the app and confirm the error now identifies the specific failing variable
    status: completed
isProject: false
---

## Background

t3-env's default handler in `@t3-oss/env-core` is:

```ts
const onValidationError = opts.onValidationError ?? ((issues) => {
  console.error("❌ Invalid environment variables:", issues);
  throw new Error("Invalid environment variables");
});
```

The per-variable details go to `console.error` only; the thrown `Error` message is generic. `createEnv` accepts a custom `onValidationError: (issues: readonly StandardSchemaV1.Issue[]) => never` where each issue has a `path` (e.g. `["SESSION_SECRET"]`) and `message`.

## Change

Update [apps/org-next/src/env.ts](apps/org-next/src/env.ts) to provide a custom `onValidationError` that formats each issue as `VAR_NAME: message` and includes them in both the log and the thrown error.

```ts
import { createEnv } from "@t3-oss/env-core";
import { z } from "zod";

export const env = createEnv({
  server: {
    API_HOSTNAME: z.url(),
    AUTH_APP_URL: z.url(),
    SESSION_SECRET: z.uuidv4(),
    MOCK_ACCESS_TOKEN: z.uuidv4(),
  },
  clientPrefix: "VITE_",
  client: {
    VITE_TEMP_BYPASS_AUTH: z.coerce.boolean(),
    VITE_ENABLE_RMP: z.coerce.boolean(),
    VITE_ROLLBAR_ACCESS_TOKEN: z.string(),
  },
  runtimeEnv: process.env,
  emptyStringAsUndefined: true,
  skipValidation: typeof window !== "undefined",
  onValidationError: (issues) => {
    const formatted = issues
      .map((issue) => {
        const path = issue.path
          ?.map((p) => (typeof p === "object" ? p.key : p))
          .join(".");
        return path ? `  - ${path}: ${issue.message}` : `  - ${issue.message}`;
      })
      .join("\n");
    console.error(`\nInvalid environment variables:\n${formatted}\n`);
    throw new Error(`Invalid environment variables:\n${formatted}`);
  },
});
```

## Notes

- `onValidationError` must have return type `never` (throw, don't return).
- `issue.path` entries can be strings, numbers, or `{ key }` path segments per Standard Schema; the mapping above handles both.
- After applying, re-run the app; the error (both in console and thrown) will name the exact variable(s), e.g. `SESSION_SECRET: Invalid UUID`.