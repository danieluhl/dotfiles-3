# Browser Capability: visibility

Browser visibility control. Use `set(true)` to present the browser visually to the user, `set(false)` to hide it, and `get()` to check whether it is currently visible. Prefer keeping browser work in the background; show the browser only when the user explicitly asks to see it or when live viewing is important. When taking screenshots to verify browser behavior, include them in progress updates when possible and include the relevant screenshots inline in the final response with Markdown image syntax unless the user asks for text only.

```ts
const capability = await browser.capabilities.get("visibility");

interface VisibilityBrowserCapability {
  get(): Promise<boolean>; // Read whether the browser is visually presented to the user.
  set(visible: boolean): Promise<void>; // Set whether the browser is visually presented to the user.
}
```
