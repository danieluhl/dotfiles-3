---
name: Fix homepage create campaign flow
overview: Delete the legacy `campaigns/new` route file (the create flow is now a dialog) and wire up the broken "Create campaign" onboarding step button on the homepage so it opens the dialog.
todos: []
isProject: false
---

## Problems found

1. **Legacy route file**: [apps/org-next/src/routes/_authed/campaigns/new.tsx](apps/org-next/src/routes/_authed/campaigns/new