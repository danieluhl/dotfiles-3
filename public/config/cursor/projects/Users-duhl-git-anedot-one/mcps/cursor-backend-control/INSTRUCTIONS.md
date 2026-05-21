The cursor-backend-control MCP calls Cursor backend APIs through the current user's authenticated Cursor session.

Automation tools:
- list_automations lists minimal, non-author-text automation rows visible to the current user. Its query matches only fields returned by the tool, such as IDs and trigger/action types.
- get_automation fetches one automation by ID with stored author text redacted and workflow values returned only as a redacted shape. Use it only after the user selected or provided the exact automation ID.
- create_automation creates an automation from a reviewed CreateAutomationRequest-shaped payload.
- update_automation updates an automation from a reviewed UpdateAutomationRequest-shaped payload.
- build_automation_prefill_url builds a cursor.com Automations prefill URL from a reviewed workflow JSON. Returns the URL string for the caller to open via open_resource or surface to the user.

Rules:
- Only call create_automation or update_automation after the user has reviewed the automation draft or requested the exact change.
- Do not invent an automation ID. If the user did not provide an ID, resolve it with list_automations, ask the user to choose from the returned IDs, and only then call get_automation when needed.
- These tools are unavailable in UNSPECIFIED and NO_STORAGE privacy modes because automations require reconciled storage eligibility.
- list_automations and get_automation require a fresh read confirmation before reading automation metadata; responses are redacted.
- create_automation and update_automation show a final confirmation modal before saving.
- build_automation_prefill_url is read-only and side-effect free; it does not call the backend, but still requires storage-eligible privacy mode because prefill serializes the draft outside the no-storage boundary.