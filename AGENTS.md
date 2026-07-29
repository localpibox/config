# LocalPibox Pi Agent Configuration

## Architecture

This Pi.dev stack is organized across 4 repositories:

1. **pi** (`localpibox/pi`) — Forked and patched Pi monorepo with `reasoning_effort` support for Qwen models
2. **lemonade-pi-plugin** (`localpibox/lemonade-pi-plugin`) — Lemonade provider plugin with Qwen reasoning model detection
3. **config** (`localpibox/config`) — This repo: settings, skills, agents, support files
4. **devstack** (`localpibox/devstack`) — Docker-based development environment

## Model Configuration

- **Provider:** lemonade (local LLM server)
- **Model:** Qwen3.6-35B-A3B-MTP-GGUF
- **API endpoint:** `http://127.0.0.1:13305/v1`
- **Thinking level:** high (default)

The Qwen3.6 model supports thinking (reasoning) via the `enable_thinking` parameter. Pi sends `reasoning_effort` alongside `enable_thinking` to control thinking depth:

| Level | `reasoning_effort` | Description |
|---|---|---|
| `high` | `"high"` | Deep, thorough reasoning |
| `medium` | `"medium"` | Balanced reasoning |
| `low` | `"low"` | Lightweight reasoning |
| `off` | — | No reasoning, direct responses |

Change thinking level with `/settings` in the Pi TUI.

## MCP Servers

### Exa (`exa`)
Web search and content fetch. Requires `EXA_API_KEY` environment variable.

Tools:
- `web_search_exa` — Search the web
- `web_fetch_exa` — Read webpage content

### Agent-Browser (`agent-browser`)
Browser automation for navigation, interaction, screenshots, and visual analysis.

Tools:
- `browser_open`, `browser_click`, `browser_fill`, `browser_type` — Navigation and interaction
- `browser_snapshot`, `browser_screenshot` — Page inspection
- `browser_eval`, `browser_get_text` — DOM access
- Vitual analysis, accessibility audits, performance metrics

### Chrome DevTools (`chrome-devtools`)
Diagnostics only. Disabled by default.

## Custom Skills

### agent-browser-mcp-integration
Browser automation workflow. Uses agent-browser MCP for navigation, screenshots, and visual analysis via local Qwen3.6 vision model.

### browser-validation
Automated browser validation pipeline. Navigate, snapshot, screenshot, vitals, accessibility audit, vision analysis, structured JSON report generation.

### mcp-vision-analysis
Analyze webpages visually using the local Qwen3.6-35B vision model.

## Custom Subagents

### researcher (`researcher.md`)
Web research specialist. Searches the web using Exa MCP and synthesizes focused research briefs.

## Support Files

Support utilities are installed to `/opt/pi-support/`:

| Path | Purpose |
|---|---|
| `/opt/pi-support/bin/session-uuid` | Generate unique session IDs for worktree isolation |
| `/opt/pi-support/bin/browser-state-cleanup` | Cleanup browser state volumes |
| `/opt/pi-support/browser` | Browser helper script |
| `/opt/pi-support/browser-validate.ts` | Browser validation entry point |
| `/opt/pi-support/config/agent-browser-action-policy.json` | Agent action policies |
| `/opt/pi-support/config/subagent-browser-prompt.txt` | Subagent browser prompt |
| `/opt/pi-support/docs/subagent-spawning-pattern.md` | Subagent spawning documentation |
| `/opt/pi-support/schemas/browser-validation-schema.json` | JSON validation schema for browser validation |
| `/opt/pi-support/schemas/subagent-browser-schema.json` | JSON validation schema for subagent browser |
| `/opt/pi-support/session-uuid.ts` | Session UUID generation utility |
| `/opt/pi-support/start.sh` | Start script |
| `/opt/pi-support/validate-subagent-output.ts` | Subagent output validation |

## Quick Reference

- `/settings` — Change thinking level, theme, delivery, transport
- `/model` — Switch models
- `/session` — Show session info
- `/tree` — Navigate session history
- `/new` — Start new session
- `!command` — Run shell command and send output to model
- `!!command` — Run shell command silently
- `@file` — Include file in message
