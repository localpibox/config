# LocalPibox Pi Agent Config

Reproducible Pi.dev agent configuration: settings, MCP servers, custom skills, subagents, and bootstrap install script.

> **⚡ [← Back to LocalPibox](https://github.com/localpibox/localpibox)** — project overview, architecture, and the full stack.

## Repository Structure

```
config/
├── AGENTS.md              # Global agent instructions
├── lpb-memory-config.json # Memory extension config
├── install.sh             # One-command bootstrap script
├── .env.example           # Environment variables template
├── mcp.json               # MCP server configuration
├── skills/                # Custom skills (installed to ~/.pi/agent/skills/)
│   ├── agent-browser-mcp-integration/
│   │   └── SKILL.md
│   ├── browser-validation/
│   │   └── SKILL.md
│   └── mcp-vision-analysis/
│       └── SKILL.md
├── agents/                # Custom subagents (installed to ~/.pi/agent/agents/)
│   ├── README.md
│   ├── _template.md
│   ├── browser-automation.md
│   ├── exa-search.md
│   └── researcher.md
└── support/               # Shared utilities (installed to /opt/pi-support/)
    ├── browser            # Source script for browser environment
    ├── browser-state-cleanup.sh
    ├── browser-validate.ts
    ├── session-uuid.ts
    ├── validate-subagent-output.ts
    ├── config/
    │   ├── agent-browser-action-policy.json
    │   └── subagent-browser-prompt.txt
    ├── docs/
    │   └── subagent-spawning-pattern.md
    └── schemas/
        ├── browser-validation-schema.json
        └── subagent-browser-schema.json
```



```bash
# Install with defaults (to ~/.pi/agent/)
bash install.sh

# Install to custom location
bash install.sh /path/to/custom/pi/agent
```

## Configuration

### settings.json
- **Provider:** lemonade (local LLM server)
- **Model:** Qwen3.6-35B-A3B-MTP-GGUF
- **Thinking:** medium (default); adjustable via `/settings` in Pi TUI
- **Packages:** extensions installed at runtime (from `settings.json#packages`):
  - `git:github.com/localpibox/lemonade-pi-plugin@lpb`
  - `git:github.com/localpibox/lpb-memory@main`
  - `npm:pi-mcp-adapter`
  - `git:github.com/localpibox/pi-subagents@lpb`
  - `npm:pi-powerline-footer`

### lpb-memory-config.json
Configuration for the lpb-memory extension:
- **consolidationTimeoutMs**: 300000 (5 min timeout for memory consolidation)
- Installed to `~/.pi/agent/lpb-memory-config.json` by `install.sh`
- Copied to runtime by devstack on container startup

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

This repo is the **configuration preset** for the LocalPibox stack. On first
container boot, these files are seeded into `~/.pi/agent/`.

| Repo | Role |
|---|---|
| [devstack](https://github.com/localpibox/devstack) | Container image + `lpb` launcher |
| [pi](https://github.com/localpibox/pi) | Pi monorepo fork (Qwen reasoning) |
| [lemonade-pi-plugin](https://github.com/localpibox/lemonade-pi-plugin) | Lemonade provider extension |
| [pi-subagents](https://github.com/localpibox/pi-subagents) | Subagent model registry |
| [lpb-memory](https://github.com/localpibox/lpb-memory) | Persistent memory extension |
| [config](https://github.com/localpibox/config) | This repo (settings, skills, agents) |

See the [devstack](https://github.com/localpibox/devstack) repo for container setup
and [localpibox.github.io](https://localpibox.github.io) for the project site.

## Contributing

See the [stack CONTRIBUTING guide](https://github.com/localpibox/devstack/blob/main/CONTRIBUTING.md).
