# LocalPibox Pi Agent Config

Reproducible Pi.dev agent configuration: settings, MCP servers, custom skills, subagents, and bootstrap install script.

## Repository Structure

```
config/
├── settings.json          # Pi global settings (providers, models, thinking)
├── mcp.json               # MCP server configuration
├── AGENTS.md              # Global agent instructions
├── install.sh             # One-command bootstrap script
├── .env.example           # Environment variables template
├── skills/                # Custom skills (installed to ~/.pi/agent/skills/)
│   ├── agent-browser-mcp-integration/
│   ├── browser-validation/
│   └── mcp-vision-analysis/
├── agents/                # Custom subagents (installed to ~/.pi/agent/agents/)
│   └── researcher.md
└── support/               # Shared utilities (installed to /opt/pi-support/)
    ├── bin/               # Session UUID, browser state cleanup
    ├── browser*           # Browser helper scripts
    ├── config/            # Agent action policies
    ├── docs/              # Documentation
    ├── schemas/           # JSON validation schemas
    └── session-uuid.ts    # Session ID generation
```

## Quick Install

```bash
# Install with defaults (to ~/.pi/agent/)
bash install.sh

# Install to custom location
bash install.sh /path/to/custom/pi/agent
```

## Configuration

### settings.json
- **Provider:** lemonade
- **Model:** Qwen3.6-35B-A3B-MTP-GGUF
- **Thinking:** high (default)
- **Packages:** pi (localpibox fork), lemonade-pi-plugin, pi-hermes-memory, pi-mcp-adapter, pi-subagents, pi-powerline-footer

### mcp.json
- **exa** — Web search and content fetch (requires EXA_API_KEY)
- **agent-browser** — Browser automation
- **chrome-devtools** — Diagnostics (disabled by default)

## Environment Variables

Copy `.env.example` to `.env` in your project directory and fill in:
- `EXA_API_KEY` — Exa MCP server API key
- `CONNECTION_TOKEN` — OpenVSCode auth token
- `EDITOR_HOST` — Editor host for VSCodium
- `ED_PORT` — Editor port

## LocalPibox Stack

This repo is part of the 4-repo LocalPibox stack:

1. **pi** — Forked monorepo with reasoning_effort patch
2. **lemonade-pi-plugin** — Qwen model detection
3. **config** — This repo (settings, skills, agents)
4. **devstack** — Docker development environment

See the [devstack](https://github.com/localpibox/devstack) repo for container setup.
