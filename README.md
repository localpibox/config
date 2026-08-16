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



```
# Install with defaults (to ~/.pi/agent/)
bash install.sh

# Install to custom location
bash install.sh /path/to/custom/pi/agent
```

## lpb-config Utility

Shipped in the devstack image at `/opt/pi-support/lpb-config.py` (symlinked to
`lpb-config` in PATH). Manage stack configuration from inside any container.

### Commands

```
lpb-config status               # Show config repo state
lpb-config update               # Fetch + fast-forward config repo
lpb-config reset [--force]      # Re-clone (destructive)
lpb-config merge                # Interactive merge
lpb-config align                # Update extension pins to latest tags

lpb-config validate             # Full stack alignment check
lpb-config workspace status     # Workspace repo branches + alignment
lpb-config workspace sync       # Symlinks + git pull
lpb-config workspace ensure     # Fix branch alignment
lpb-config workspace sync --extensions  # Sync extension pins to VERSION

lpb-config memory show          # Show lpb-memory config
lpb-config memory setup         # Interactive config wizard
lpb-config memory setup --non-interactive  # Generate from template
```

### Pipeline override

```
lpb-config --tag main validate   # Force main pipeline check
lpb-config --tag dev workspace ensure
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

Configuration for the lpb-memory extension. Generated at first boot from
`lpb-memory-config.json.template` — the template is tracked, the config is not.

```bash
# Review current config
lpb-config memory show

# Interactive setup wizard
lpb-config memory setup

# Non-interactive (from template)
lpb-config memory setup --non-interactive
```

Default settings (from template):
- **reviewTransport**: subprocess (offload to NPU)
- **memoryMode**: legacy-inject (visible to AI every turn)
- **memoryCharLimit**: 3000 (context optimized)
- **failureInjectionMaxEntries**: 3
- **No llmModelOverride** — uses main model (user configures after /login)

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
