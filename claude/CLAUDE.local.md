# Personal Instructions

## Session Initialization

At the start of every session, do the following automatically without being asked.

### Verify Containers Are Running

Before starting any task, check both endpoints:
```
curl -s -o /dev/null -w "%{http_code}" 127.0.0.1:9000/system/ready/
curl -s -o /dev/null -w "%{http_code}" 127.0.0.1:8000/systems/healthcheck/
```
- If **both** return non-200: run `dc up -d` and wait for it to complete before proceeding.
- If only **`:9000`** returns non-200: run `restart ssr`.
- If only **`:8000`** returns non-200: run `restart web`.

### Load Jira Ticket from Branch

If the current git branch name matches `DEV-\d+` (e.g. `DEV-143043`), extract that ticket ID and fetch the full Jira ticket using the Atlassian MCP tool. Keep it in context for the duration of the session — use it to inform PR descriptions, commit messages, code decisions, and any authoring.

### Load Project-Specific Prompts

I maintain a Confluence doc with project-specific context (Figma links, functional specs, technical specs, related PRs, Jira links, PR template context) at:
https://roverdotcom.atlassian.net/wiki/spaces/~6241e4f345ece00069c82675/pages/5827725833/Project+Specific+Claude+Prompts

If I indicate we are working on one of the projects listed in that doc:
1. Fetch the Confluence doc using the Atlassian MCP tool.
2. Write its full contents to `/tmp/project-specific-prompts.md`, overwriting any previous version.
3. Reference that file throughout the session. Do not rely on memory — re-fetch at the start of each relevant session.

## MCP Server Authentication

If you encounter an authentication error, permissions error, or connection failure with any MCP server (Atlassian, Statsig, etc.), **stop immediately**. Do not attempt to work around it, skip the step, or proceed without the data. Instead, tell me exactly which MCP server failed and what the error was, and wait for me to resolve it before continuing.

## Git Push & Commit Policy

Never push to a branch or update a PR unless I explicitly tell you to in the current session. Do not assume that approval to commit also means approval to push. I will tell you when to push individual commits. Always defer to me on both committing and pushing.

### Rebasing

When I ask you to rebase, first disable the VS Code interactive rebase editor by running:
```
git config --global sequence.editor "cat"
```
Then proceed with the rebase. This prevents VS Code from hijacking the rebase with its interactive editor.

## Auto-Run Commands

Run these automatically when the relevant conditions are met. Do not ask for confirmation.

### Schema Generation

When any serializer file is changed (e.g. `**/serializers.py` or `**/serializers/**`), run `makeschemas` to regenerate both backend and frontend schemas. Always run both together. Never modify generated schema files directly. Run in the background so it does not block current work.

### SSR Restart

**REQUIRED:** After completing any task that involved changes to files in `src/frontend/react-lib/` or `src/frontend/react-app/`, run `restart ssr`. Do not skip this step.

### React Native Server

When asked to start the React Native server, also run `preload_rxn` in the background to prewarm the server.

## Authoring Style

When creating or editing any content (PRs, Jira tickets, Confluence docs) on my behalf:
- Always include links to relevant functional specs, Figma designs, or other reference docs available in context. Do not omit links you have access to.
- Do not include effort estimates.
- Tone is direct and casual. No corporate speak or passive voice.

### Confluence

Reference these documents for tone and structure:
- [Mini-IP: Generic Dismissable Daily Dashboard Items](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5741543569)
- [SPIKE: Groomer Sign Up Concept Test](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5214997661)
- [SPIKE: Grooming Request/Booking Spec Review](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5578850350)

Key traits:
- **Direct and first-person.** Use "I" and "we". State opinions clearly ("I believe", "I recommend"). Don't hedge.
- **Short paragraphs.** 1-3 sentences. Get to the point.
- **Always start with a "Background" section** — brief context, links to tickets/specs/PoCs, purpose in 1-2 sentences.
- **Explicitly scope the document.** Call out what is and isn't addressed, with brief justifications.
- **Link to code, don't paste it.** Use inline links to GitHub lines/files. Small pseudocode snippets are fine for illustrating patterns.
- **Present options with tradeoffs.** State a clear preference and explain why.
- **Use "Action Items" bullet lists** at the end of implementation subsections.
- **Link heavily** to PRs, tickets, Slack threads, and code.

### Jira Tickets

Reference these tickets for tone and structure:
- [DEV-137451](https://roverdotcom.atlassian.net/browse/DEV-137451) - Create GroomingContactPageAPIView
- [DEV-137452](https://roverdotcom.atlassian.net/browse/DEV-137452) - Setup Grooming Contact page skeleton
- [DEV-137456](https://roverdotcom.atlassian.net/browse/DEV-137456) - Build out "Last Groomed", "Notes for Groomer", and ToS
- [DEV-137459](https://roverdotcom.atlassian.net/browse/DEV-137459) - Pull phone input into contact page

Key traits:
- **Summaries are short and action-oriented.** Imperative verbs: "Build out", "Create", "Setup", "Pull", "Add". No filler.
- **Descriptions start with 1-2 sentences of context** — why this work exists, what it depends on, with inline links to code or designs.
- **Always include a `DoD:` (Definition of Done) section** with concrete acceptance criteria as bullet points.
- **Use sub-bullets for detail** when a field or item needs additional explanation.
- **Acknowledge unknowns and defer when appropriate.**
- **Set up blocking relationships** between tickets when creating multiple tickets for a project.

### Pull Requests

Always create PRs as **draft** PRs. Never publish (mark ready for review) unless I explicitly say so.

Reference these PRs for tone and structure:
- [#89075](https://github.com/roverdotcom/web/pull/89075) - Create `GroomingTestimonialApiView`
- [#90215](https://github.com/roverdotcom/web/pull/90215) - Add middleware to set `x-back-history` and `x-back-url` on Django responses
- [#88426](https://github.com/roverdotcom/web/pull/88426) - Create new AddOnTypes for grooming
- [#88576](https://github.com/roverdotcom/web/pull/88576) - Create GroomingServiceSettings views and serializers

Key traits:
- **"What is the reason for this pull request?"** — 1-2 sentences, or a short bulleted list for multiple changes.
- **Deployment section** — 1-2 bullets each for "How can I tell if this change has been deployed?" and "Did anything break?"
- **Code Review Instructions** — "Before testing" (setup: fixtures, shell commands, config) and "Acceptance tests" (checkboxes with exact steps).
- **Acceptance tests are specific and reproducible.** Include exact API endpoints, JSON payloads, shell commands, navigation steps.
- Never check off the acceptance tests
- Never fill out the accessibility section of the PR template — leave it exactly as templated
- Never fill out or indicate anything about AI usage in the PR template — leave it exactly as templated
- Both sections are for the PR author to complete; do not touch them

## Frontend Code Style

### Business Logic Placement

When building a new frontend page, defer business logic to the backend as much as possible — the frontend should primarily handle rendering and user interaction. When working on an existing page, use your judgement based on the patterns already in place.

### Colors

Never use hardcoded hex colors or other raw color values. Always resolve colors in this order of preference:

1. **Rover theme tokens** via the `useTheme()` hook — theme values are defined in `src/frontend/kibble/tokens/build/rover/es6/theme.ts`. Defer to these pregenerated constants as much as possible.
2. **`RoverColor` enum** — check for a matching entry before reaching for anything else.

If a color cannot be found in either the theme or `RoverColor`, flag it rather than falling back to a hardcoded value.

## Prompt Logging

Keep a verbatim running log of substantial prompts I give you. Do not paraphrase, summarize, or alter my language. Group prompts from the same task under a single timestamp.

Only include prompts that represent meaningful direction or requests. Skip simple answers to your clarifying questions (e.g. "yes", "no", "the second one"). If a prompt contains the word `HIDDEN`, omit it from the log entirely.

### Tracking Prompts and Timing Across the Session

Start tracking prompts from the very beginning of the session — not just after entering plan mode. When a prompt triggers plan mode, all prior substantial prompts from the session should be included in the log.

Persist everything to `/tmp/claude-session-log.md`. Append each new prompt immediately. For each prompt, also track how long Claude spent working on it (wall-clock time from receiving the prompt to completing the response/task). Record the elapsed time inline with the prompt. You should also dump any relevant session data (ID, date, etc.) so that upon compaction or clearing context, you can successfully recreate the prompt history.

On compaction, read from this file to recover the full history.

### Format

Format each prompt as a markdown blockquote with elapsed time, not backticks:
```
---

## Appendix: Prompts

### YYYY-MM-DD

> Exact prompt text here.

*Claude elapsed time: 1m 32s*

> Another prompt here.

*Claude elapsed time: 4m 15s*

**Total Claude elapsed time: 5m 47s**
```

### Where to Append

**PRs** — Append a "Claude Prompts" appendix to the PR description and update it each time you push or update the description.

**Confluence docs** — Append the same format as a "Prompts" section at the bottom of the page.

**Jira tickets** — Add the prompts as a comment on the ticket when creating it.

