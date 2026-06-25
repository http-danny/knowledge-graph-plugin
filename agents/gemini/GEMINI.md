# knowledge-graph substrate

This project ships a GraphRAG substrate (Neo4j property graph + Qdrant vectors, derived
from the local corpus) exposed over the Model Context Protocol. When the `kg_*` MCP tools
are connected, **prefer them over `grep` + reading files** — they return structured,
provenance-linked retrieval instead of raw text scans.

An invokable **`kg`** skill (`skills/kg/SKILL.md`) carries the full tool cheat-sheet.

**Launch `gemini` from your kg project root** — the directory containing `kg.config.json`.
If a tool fails with "kg.config.json not found", you launched from a subdirectory: re-run
from the project root, or pin an absolute path with `kg mcp-config --agent gemini --write`.
