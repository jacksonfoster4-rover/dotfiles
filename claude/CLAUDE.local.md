# Personal Instructions

## Prompt Logging

Whenever working on a task, keep a running log of every prompt I give you verbatim. Do not paraphrase, summarize, or alter my language in any way.

If multiple prompts are given in rapid succession as part of the same task, group them together under a single timestamp, but still preserve the exact wording of each prompt.

### GitHub Pull Requests

When working with a PR where I am the author, append a "Claude Prompts" appendix to the PR description containing every prompt I gave you during that session. Format:

```
---

## Appendix: Prompts

### YYYY-MM-DD

- `<exact prompt text>`
- `<exact prompt text>`

### YYYY-MM-DD

- `<exact prompt text>`
```

Update this appendix each time you push changes or update the PR description.

### Confluence Documents

When updating a Confluence page where I am the author, include a similar "Prompts" appendix at the bottom of the document with the same format as above.

### Jira Tickets

When creating Jira tickets on my behalf, add the prompts that led to the ticket's creation as a comment on the ticket, preserving exact wording.

## Auto-Run Commands

### Schema Generation

Whenever a serializer file is changed (e.g. anything under `**/serializers.py` or `**/serializers/**`), run `makeschemas` to regenerate both backend and frontend schemas. Always run both together, even if only backend code was changed. Never modify generated schema files directly. Run this command in the background (e.g. via a background agent or `run_in_background`) so it does not block the current work.

### SSR Restart

Whenever code in `react-lib` or `react-app` is changed, run `restart ssr`.

### React Native Server

When asked to start the React Native server, also run `preload_rxn` in the background (e.g. via a background agent or `run_in_background`) to prewarm the server. Do not block the current work waiting for it.

## Confluence Writing Style

When writing or editing Confluence documents on my behalf, match my personal writing style. Reference these documents for tone and structure:

- [Mini-IP: Generic Dismissable Daily Dashboard Items](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5741543569)
- [SPIKE: Groomer Sign Up Concept Test](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5214997661)
- [SPIKE: Grooming Request/Booking Spec Review](https://roverdotcom.atlassian.net/wiki/spaces/TECH/pages/5578850350)

Key traits of my style:

- **Direct and first-person.** Use "I", "we", and state opinions clearly ("I believe", "I recommend", "I don't see this taking more than..."). Do not hedge excessively or use passive voice.
- **Short paragraphs.** Typically 1-3 sentences. Get to the point quickly.
- **Always start with a "Background" section** that provides brief context, links to relevant tickets/specs/PoCs, and states the purpose of the document in 1-2 sentences.
- **Explicitly scope the document.** Call out what is and is not addressed (e.g. "This SPIKE addresses… / It does not address…") with brief justifications for exclusions.
- **Link to code, don't paste it.** Reference specific GitHub lines/files with inline links rather than embedding large code blocks. Use small pseudocode snippets only when illustrating a proposed pattern.
- **Present options with tradeoffs** when there are multiple approaches, state a clear preference, and explain why.
- **Do not include effort estimates.** You do not have enough context to estimate.
- **Use "Action Items" bullet lists** at the end of implementation subsections to summarize deliverables.
- **Link heavily** to PRs, tickets, Slack threads, and code — prefer inline links over embedding full content.

## Jira Ticket Style

When creating Jira tickets on my behalf, match my personal style. Reference these tickets for tone and structure:

- [DEV-137451](https://roverdotcom.atlassian.net/browse/DEV-137451) - Create GroomingContactPageAPIView
- [DEV-137452](https://roverdotcom.atlassian.net/browse/DEV-137452) - Setup Grooming Contact page skeleton
- [DEV-137456](https://roverdotcom.atlassian.net/browse/DEV-137456) - Build out "Last Groomed", "Notes for Groomer", and ToS
- [DEV-137459](https://roverdotcom.atlassian.net/browse/DEV-137459) - Pull phone input into contact page

Key traits of my ticket style:

- **Summaries are short and action-oriented.** Use imperative verbs: "Build out", "Create", "Setup", "Pull", "Add". No filler words.
- **Descriptions start with 1-2 sentences of context** explaining why this work exists or what it depends on. Link to existing code or designs inline.
- **Link to Figma design nodes and GitHub code** directly in the description rather than embedding screenshots or pasting large code blocks.
- **Always include a `DoD:` (Definition of Done) section** with bullet points listing the concrete acceptance criteria.
- **Use sub-bullets for detail** when a field or item needs additional explanation (e.g. what a field represents, what it will eventually become, current stub behavior).
- **Acknowledge unknowns and defer when appropriate** (e.g. "This may work without Grooming SSU, but I will defer to the implementer").
- **Set up blocking relationships** between tickets to show dependency order when creating multiple tickets for a project.
- **Keep it practical.** No fluff — just what needs to happen and what "done" looks like.

## Pull Request Style

When creating or updating PR descriptions on my behalf, match my personal style. Reference these PRs for tone and structure:

- [#89075](https://github.com/roverdotcom/web/pull/89075) - Create `GroomingTestimonialApiView`
- [#90215](https://github.com/roverdotcom/web/pull/90215) - Add middleware to set `x-back-history` and `x-back-url` on Django responses
- [#88426](https://github.com/roverdotcom/web/pull/88426) - Create new AddOnTypes for grooming
- [#88576](https://github.com/roverdotcom/web/pull/88576) - Create GroomingServiceSettings views and serializers

Key traits of my PR style:

- **"What is the reason for this pull request?"** — 1-2 sentences max. State what the PR does concisely. If there are multiple changes, use a short bulleted list.
- **Deployment section** — Keep answers brief. "How can I tell if this change has been deployed?" and "Did anything break?" should each be 1-2 bullet points describing what success and failure look like.
- **Code Review Instructions** — Split into "Before testing" (setup steps: fixtures, shell commands, config changes) and "Acceptance tests" (checkbox items with concrete steps the reviewer can follow).
- **Acceptance tests are specific and reproducible.** Include exact API endpoints, JSON payloads, shell commands, and navigation steps. Use checkboxes for each verification point.
- **Do not include effort estimates.**
- **Tone is direct and casual.** No corporate speak.

## Cross-Linking

When authoring Jira tickets, PRs, or Confluence documents on my behalf, always include links to relevant functional specs, Figma designs, or other reference documents that are available in the current context. Do not omit links you have access to.

## Project-Specific Prompts

I store project-specific Claude prompts in `~/.claude/prompts/web/`. At the start of a task, check this directory for any `.md` files that are relevant to the current work. Read and follow any matching prompts. Files are named by project or topic (e.g. `grooming-contact-page.md`, `dashboard-items.md`).

