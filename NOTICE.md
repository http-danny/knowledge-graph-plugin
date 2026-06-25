# NOTICE

This plugin vendors seven skills from [neo4j-contrib/neo4j-skills](https://github.com/neo4j-contrib/neo4j-skills) (MIT). Their full LICENSE travels with the vendored content at [`skills/LICENSE-neo4j-contrib-neo4j-skills`](skills/LICENSE-neo4j-contrib-neo4j-skills). Per-skill provenance (commit SHA + date) is in each skill's `.vendor-source.txt`.

## Vendored skills

- `skills/neo4j-cypher-skill/` — Cypher 25 query authoring, optimization, validation
- `skills/neo4j-modeling-skill/` — graph data modeling and refactoring
- `skills/neo4j-vector-index-skill/` — vector index creation, embedding storage, ANN/kNN search
- `skills/neo4j-graphrag-skill/` — GraphRAG retrieval pipelines (neo4j-graphrag Python package)
- `skills/neo4j-mcp-skill/` — installing and configuring the official Neo4j MCP server
- `skills/neo4j-getting-started-skill/` — zero-to-running-app onboarding orchestration
- `skills/neo4j-agent-memory-skill/` — neo4j-agent-memory package and POLE+O memory model

All skills were vendored verbatim from upstream commit `5c2d74082f2a5f0500bc13e74526f9d27bb80ed8` (2026-04-30) with no modifications. Each skill directory has a `.vendor-source.txt` recording exact origin path, commit SHA, and vendoring date.

The skills are loaded by Claude Code at install time via the `skills` glob in [`plugin.json`](plugin.json) (`./skills/**/*.md`), which matches each `SKILL.md` (and any nested `references/`/`scripts/` markdown).

## Maintenance

Review annually or when downstream Cypher / Vector / Knowledge Graph capability changes (e.g. new Cypher major release, new Neo4j vector index features, new Neo4j GraphRAG API). Sync workflow:

1. Re-clone `neo4j-contrib/neo4j-skills` and capture the new HEAD SHA.
2. Diff the upstream skill directories against the vendored copies under `plugin/skills/`.
3. Apply changes verbatim and update each touched `.vendor-source.txt` with the new SHA + date.
4. Update this NOTICE.md if the set of vendored skills changes.
