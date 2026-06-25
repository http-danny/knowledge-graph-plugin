---
name: kg
description: Retrieve over the knowledge-graph substrate (hybrid GraphRAG + code intelligence) instead of grep + reading files.
---

# Using the knowledge-graph substrate

This repository ships a **GraphRAG substrate** (Neo4j property graph + Qdrant vectors,
derived from the local corpus) exposed over the Model Context Protocol. When these MCP
tools are connected, **prefer them over `grep` + `Read` across markdown and code** —
they return structured, provenance-linked retrieval instead of raw text scans.

## Tools (read-only)

| Tool | Use it to… |
|---|---|
| `kg_search` | Hybrid (graph + vector) search over prose + code for a question. |
| `kg_code_semantic_search` | Find code symbols by meaning (NL → symbols). |
| `kg_code_neighbors` | Walk a symbol's callers/callees/imports. |
| `kg_code_tour` | List or replay a guided tour of a feature/subsystem. |
| `kg_impact` | What a change to a symbol would affect (blast radius). |
| `kg_code_source` | Read a symbol's exact source slice from disk. |
| `kg_sql_lineage` | Walk a SQL symbol's lineage neighborhood — what it executes, queries, writes, and selects from, plus surrounding data-structure context. |
| `kg_context_search` | Semantic search over the Context layer (decisions, rationales, context events). |
| `kg_decision_trace` | Trace a decision's causal chain — its rationales, context, decider, and subjects, plus the decisions and outcomes it caused, led to, influenced, superseded, or resulted in. |
| `kg_find_precedents` | Find prior decisions similar to a situation ("have we decided something like this before?"). |
| `kg_outcomes` | Search realized outcomes (wins) + each win's decision→production evidence trace. |
| `kg_user_context` | Read the operator's own User layer — their profile (who they are), preferences (how they want the agent to work), and saved queries — for the active corpus. Semantic or structural; filter by types/preferenceKinds. Local-only, never egresses. |
| `kg_agent_sessions` | List/filter recorded agent (Claude Code) sessions by repo, date range, or actor. |
| `kg_session_activity` | A session's tool-call timeline + its actors + any decisions that reference it. |
| `kg_actor_activity` | What a reconciled actor did across markdown decisions AND agent sessions. |
| `kg_work_items` | List/filter work items (e.g. Jira issues) by project, status, assignee, or last-updated range. |
| `kg_work_item_activity` | A work item's status-change timeline + comments + assignee/reporter + the local specs/decisions that address or fulfill it (the SDLC trace) + the assignee/reporter's other decisions & sessions. |
| `kg_work_item_search` | Semantic search over ingested work items (find issues by meaning). |
| `kg_pull_requests` | List/filter pull requests by repo, state, author, or last-updated range. |
| `kg_pull_request_activity` | A pull request's review/comment timeline + author/reviewers/assignees + the merge commit + the files it affects + the local work items that implement or contradict it (the SDLC trace) + the decisions whose context snapshots the merge commit + the author/reviewers' other decisions & sessions. |
| `kg_vcs_search` | Semantic search over ingested pull requests & reviews (find by meaning). |
| `kg_deployments` | List/filter deployments & CI builds by repo, environment, status, sha, or last-updated range — the DEPLOYED→commit + PRODUCED←build chain + any deploy-vs-status contradiction. |
| `kg_incidents` | List/filter incidents by service, status, urgency, assignee, or date. |
| `kg_incident_activity` | An incident's event timeline + alerts + escalations & on-call + the fix/SDLC loop (triggered work item → pull request → merge commit → deployment) + any contradictions + the responders' other decisions & sessions. |
| `kg_cicd_search` | Semantic search over ingested incidents (find by meaning). |
| `kg_chat_threads` | List/filter chat threads (Teams / Google Chat) by system, channel/space, date, or participant. |
| `kg_thread_activity` | A chat thread's message timeline + participants + the incidents discussed in it (the war-room view) + linked decisions (human-authored and chat-mined, each labeled) + any contradictions. |
| `kg_chat_search` | Semantic search over ingested chat messages (find by meaning). |
| `kg_meeting_search` | Semantic search over ingested meetings & action items (find by meaning). |
| `kg_meeting_activity` | A meeting's attendees + action items (with the work items they are tracked as) + decisions mined from it (labeled by source/confidence) + the incidents discussed in it (the postmortem view) + any same-as counterpart meeting (a calendar event ↔ its Zoom session). |
| `kg_action_items` | List/filter action items captured from meetings by assignee, meeting, source (provider/meeting-mined), or tracked-status (has/lacks a tracked-as work item). |
| `kg_email_threads` | List/filter email threads (Gmail / Outlook) by system, label/folder, date, or participant. |
| `kg_email_activity` | An email thread's message timeline + participants + linked decisions (human-authored and email-mined, each labeled) + action items (with the work items they are tracked as) + the work items / pull requests / incidents discussed in it (the SDLC trace) + any contradictions. |
| `kg_email_search` | Semantic search over ingested email messages (find by meaning). |
| `kg_docs` | List/filter wiki pages (Confluence) by space, label, content type, author, parent (the page hierarchy), or last-modified range. |
| `kg_docs_activity` | A wiki page's metadata + authors/editors + linked decisions (human-authored and wiki-mined, each labeled) + the code symbols it references and local docs it is about + the work items / pull requests / incidents discussed in it (the SDLC trace) + any contradictions. |
| `kg_docs_search` | Semantic search over ingested wiki pages (find by meaning), optionally restricted to one space or label. |
| `kg_design` | List/filter design files & mockups (Figma) by project, team, file, kind (frame/screen/component/componentSet), author, parent file (the file↔mockup hierarchy), or last-modified range. |
| `kg_design_activity` | A design file/mockup's metadata + owner/editors + linked decisions (human-authored and figma-mined, each labeled) + the code symbols a mockup is about (the ABOUT_CODE design→code surface) + the work items / pull requests discussed in it (the SDLC trace) + any contradictions. |
| `kg_design_search` | Semantic search over ingested design files & mockups (find by meaning), optionally restricted to one file, kind, or project. |
| `kg_node_neighborhood` | Expand a graph node's immediate relationships. |
| `kg_describe_schema` | Inspect labels + relationship types before querying. |

(The three agent-session tools are registered only when the `agent-sessions` connector
family is enabled in `kg.config.json`. The `sql` connector family adds two more
**dynamically-registered** read tools when enabled: `kg_sql_catalog` (list ingested SQL objects
per database connection) and `kg_data_search` (semantic search over ingested SQL **rows** — present
only when row embedding is on). The `work-trackers` connector family adds three more
**dynamically-registered** read tools when enabled (config block `connectors.jira`): `kg_work_items`,
`kg_work_item_activity`, and `kg_work_item_search` (the last present only when work-item embedding is
on). The `vcs` connector family adds three more **dynamically-registered** read tools when enabled
(config block `connectors.github`): `kg_pull_requests`, `kg_pull_request_activity`, and `kg_vcs_search`
(the last present only when VCS embedding is on). The `ci-cd` connector family — the first
**multi-connector** family (config blocks `connectors.githubActions` and/or `connectors.pagerduty`) —
adds four more **dynamically-registered** read tools when enabled: `kg_deployments`, `kg_incidents`,
`kg_incident_activity`, and `kg_cicd_search` (the last present only when ci-cd embedding is on). The
`chat` connector family — the second **multi-connector** family (config block `connectors.chat` with
nested `teams` and/or `googleChat` systems) — adds three more **dynamically-registered** read tools
when enabled: `kg_chat_threads`, `kg_thread_activity`, and `kg_chat_search` (the last is **always**
registered with the family, but returns an empty result when chat embedding is off — the default).
The `meetings` connector family — the third **multi-connector** family (config block
`connectors.meetings` with nested `zoom` and/or `googleCalendar` systems) — adds three more
**dynamically-registered** read tools when enabled: `kg_meeting_search`, `kg_meeting_activity`, and
`kg_action_items` (`kg_meeting_search` is **always** registered with the family, but returns an empty
result when meeting embedding is off — the default). The `email` connector family — the fourth
**multi-connector** family (config block `connectors.email` with nested `gmail` and/or `outlook`
systems) — adds three more **dynamically-registered** read tools when enabled: `kg_email_threads`,
`kg_email_activity`, and `kg_email_search` (`kg_email_search` is **always** registered with the family,
but returns an empty result when email embedding is off — the default). The `docs` connector family —
the FIRST **single-connector** family in this batch (config block `connectors.docs` with a nested
`confluence` system) — adds three more **dynamically-registered** read tools when enabled: `kg_docs`,
`kg_docs_activity`, and `kg_docs_search` (`kg_docs_search` is **always** registered with the family, but
returns an empty result when docs embedding is off — the default; list/filter pages structurally via
`kg_docs` instead). Wiki pages are `:Document:WikiPage` nodes (the file-owned `:Document` core reused for
an external source), scoped to `:WikiPage` so local markdown documents never appear in `kg_docs` /
`kg_docs_activity`; **note the asymmetry: wiki pages surface via `kg_docs_search`, NOT `kg_search`** (the
hybrid `kg_search` covers the local prose/code corpus, not connector-sourced wiki bodies). The `design`
connector family — the SECOND **single-connector** family in this batch (config block `connectors.design`
with a nested `figma` system; Zeplin / "Claude design" are documented roadmap) and the EIGHTH and FINAL
connector family — adds three more **dynamically-registered** read tools when enabled: `kg_design`,
`kg_design_activity`, and `kg_design_search` (`kg_design_search` is **always** registered with the family,
but returns an empty result when design embedding is off — the default; list/filter design nodes
structurally via `kg_design` instead). Design artifacts are `:DesignArtifact` (the file) / `:Mockup` (a
frame/screen/component) nodes — **net-new Knowledge primaries, NOT the file-owned `:Document` core** —
scoped to those labels so local markdown documents + code never appear in `kg_design` /
`kg_design_activity`; **note the same asymmetry: design nodes surface via `kg_design_search`, NOT
`kg_search`** (the hybrid `kg_search` covers the local prose/code corpus, not connector-sourced design
bodies — which embed text-only, never images). Decisions
mined from meeting transcripts, email threads, wiki pages, **and Figma comments** also surface in the existing
`kg_context_search`/`kg_find_precedents` (one unified decision surface, labeled by
`source`/`confidence`; the positive `sourceSystem` filter now also accepts
`zoom`/`google-calendar`/`gmail`/`outlook`/`confluence`/`figma`). When the chat or email family is enabled
alongside `agent-sessions`, `kg_actor_activity` additionally surfaces the actor's chat threads / email
threads. The **User layer** (the operator's own profile/preferences/saved-queries — the most private,
per-operator, opt-in, **never-egress** layer) is surfaced by the **always-registered** `kg_user_context`
tool: it returns an **empty** result when the User layer is disabled (`user.enabled:false`, the default)
and reads only the LOCAL graph + LOCAL `user` collection (no cloud call). The operator authors User
state with the CLI verbs **`kg pref`** (`set`/`get`/`list`/`rm`), **`kg savedquery`** (`save`/`list`/`rm`),
and **`kg user forget`** (RTBF — delete every User node + its source files + local vectors); these author
state files (files are source of truth) that the next `kg ingest` mints into the graph. Under the default
**`safe`** tool profile, raw-Cypher tools are not exposed; the kg maintainer can enable them with
`--profile full`.)

When a connector can only partially ingest a source (a missing OAuth scope, resource permission, or
plan tier), `kg` degrades rather than aborting: the primary record still ingests, `kg doctor` shows a
degraded-ingestion matrix, and `kg connectors fetch` prints a WARN — see
`docs/connectors/scopes-and-permissions.md` for the per-family scope/plan reference.

The web console (`kg web`) manages every connector family without hand-editing
`kg.config.json`: a **Connectors** page under *Configure* lets you configure a connection,
**secure** a secret (to a gitignored env file or the OS keychain — the value never lands in
config or git), **scope/map** it (per-family scoping + embedding/mining toggles + the SQL
`table→label` selector, whose labels come from the registry Knowledge layer), **fetch/test/
delete** it as streamed jobs, and **schedule** a recurring fetch. The console also offers a
read-only **browse & trace** view of connector data at `/explore/connectors` (under *Explore*) —
a projection of the family `*_activity` / list / search handlers for all eight families: filter
a family's items, open one for its full activity/SDLC trace, follow cross-family deep-links, and
run a per-family semantic search lens. Plus per-system ingestion tiles on the *Operate* dashboard
and a live enabled-tool list on **Connect agents**. (These are web-console + HTTP-API affordances;
they add no MCP tool — the read tools above are unchanged.)

## How to connect another agent

The substrate is built by the agent-agnostic `kg` CLI (`kg ingest`). To wire these tools
into your agent, run **`kg mcp-config --agent <name>`** (cursor, vscode, windsurf, gemini,
cline, zed, codex, opencode, continue) and follow the printed instructions, or use the
web console's **Connect agents** panel (`kg web`). See `README.md` → "Use from other agents".

The Claude/Gemini/Codex native bundles are published to the dedicated
`http-danny/knowledge-graph-plugin` repo (generated from this one). Claude Code:
`/plugin marketplace add http-danny/knowledge-graph-plugin`.

## Launching under Codex CLI

These tools are served by the `kg` MCP server bundled in this Codex plugin, under the
read-only **`safe`** tool profile (raw-Cypher tools are not exposed).

**Install** (from a checkout of this repo, or by GitHub shorthand):

```
codex plugin marketplace add .            # or: codex plugin marketplace add http-danny/knowledge-graph
codex plugin add knowledge-graph@knowledge-graph-marketplace
```

**Point it at your corpus.** The bundled server runs from the plugin directory, so it needs to
know where your `kg.config.json` is — Codex has no project-path variable for plugin servers.
Either:

- **Export the path** before launching `codex`: `export KG_CONFIG_PATH="$PWD/kg.config.json"`
  (the bundle forwards `KG_CONFIG_PATH` from your shell), or
- **Pin it once (robust):** `kg mcp-config --agent codex --write` writes a `~/.codex/config.toml`
  `[mcp_servers.kg]` entry with an absolute path that overrides this bundle.

If a tool fails with "kg.config.json not found", you have not pinned the config — do one of the
above.
