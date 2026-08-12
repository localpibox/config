# Contributing to LocalPibox config

This repo is the **Pi agent configuration preset**: settings, MCP servers,
custom skills, subagents, and support utilities. It is installed to
`~/.pi/agent/` and `/opt/pi-support/` at container startup.

## What to work on

- **`settings.json` / `mcp.json` / `pi-defaults.json` / `subagents.json`** —
  runtime agent behavior, providers, MCP servers, extension installs.
- **`skills/`** — reusable procedures (each skill is a `SKILL.md`).
- **`agents/`** — subagent definitions. Always default to `model: parent`;
  never hardcode a model.
- **`support/`** — utilities installed to `/opt/pi-support/` (browser
  validation, session UUID, subagent output validation).
- **`install.sh`** — the bootstrap that seeds `~/.pi/agent/`.

## Process

1. Fork the repo, branch off `main`.
2. Make focused, minimal changes and keep `settings.json#packages` in sync with
   this README.
3. Open a PR against `main`.

See the full guide at
[devstack/CONTRIBUTING.md](https://github.com/localpibox/devstack/blob/main/CONTRIBUTING.md).
