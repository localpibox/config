---
name: mcp-vision-analysis
description: Analyze webpages visually using the local vision model (Qwen3.6-35B) via chrome-devtools MCP or agent-browser CLI.
---

# MCP + Local Vision Workflow

## When to Use

When you need to analyze a webpage visually using the local vision model (Qwen3.6-35B) via the chrome-devtools MCP server or agent-browser CLI.

## Hybrid: MCP + agent-browser

For **interaction-heavy** workflows, combine with [agent-browser](https://agent-browser.dev/) (see `agent-browser-mcp-integration` skill):
- Use `agent-browser snapshot -i` for **compact DOM** (~200-400 tokens, ref-based element selection)
- Use `agent-browser screenshot --annotate` for **annotated screenshots** with numbered bounding boxes
- Use `chrome-devtools-mcp` for **visual analysis** and **diagnostics**

### agent-browser workflow (recommended for interaction)

```bash
# Navigate + get compact accessibility tree
agent-browser open https://site.com
agent-browser snapshot -i
# → heading "Example Domain" [ref=e1]
# → link "More info" [ref=e2]

# Interact deterministically
agent-browser click @e2
agent-browser type @e3 "hello"

# Screenshot for visual analysis
agent-browser screenshot --annotate /tmp/annotated.png
# → numbered labels [1], [2], [3] match refs @e1, @e2, @e3
```

### When to use which

| Task | Use | Why |
|------|-----|-----|
| "What does this page look like?" | chrome-devtools-mcp screenshot → local vision | Visual analysis |
| "Click the login button" | agent-browser snapshot + `click @ref` | Deterministic refs, 200 tokens |
| "Fill the form" | agent-browser `type @ref "value"` | Precise element targeting |
| "Navigate and check layout" | chrome-devtools-mcp screenshot → local vision | Color, spacing, visual hierarchy |
| "Test a user flow" | agent-browser + MCP screenshot at key steps | Interaction + visual verification |
| "Check for memory leaks" | chrome-devtools-mcp `take_heapsnapshot` | Diagnostics |
| "Profile page performance" | chrome-devtools-mcp `performance_start_trace` | Diagnostics |

## MCP Vision Procedure (visual analysis only)

### Step 1: Navigate

```
chrome_devtools_navigate_page(url="https://...")
```

### Step 2: Screenshot (optimized)

For **lightweight pages** (text-heavy, simple layouts):
```
chrome_devtools_take_screenshot(filePath="/tmp/vision-ss.png", format="jpeg", quality=60)
```

For **heavy pages** (videos, animations, rich media):
1. First, block media resources:
   ```
   chrome_devtools_evaluate_script(function="document.querySelectorAll('iframe,video,source,picture,canvas,svg').forEach(el => el.remove());")
   ```
2. Then screenshot:
   ```
   chrome_devtools_take_screenshot(filePath="/tmp/vision-ss.png", format="jpeg", quality=50)
   ```

### Step 3: Analyze with Local Model

```bash
SS_BASE64=$(base64 -w 0 /tmp/vision-ss.png)
curl -s http://127.0.0.1:13305/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "{\n    \"model\": \"Qwen3.6-35B-A3B-MTP-GGUF\",\n    \"messages\": [\n      {\n        \"role\": \"user\",\n        \"content\": [\n          {\"type\": \"text\", \"text\": \"$PROMPT\"},\n          {\"type\": \"image_url\", \"image_url\": {\"url\": \"data:image/jpeg;base64,$SS_BASE64\"}}\n        ]\n      }\n    ],\n    \"max_tokens\": 1024,\n    \"stream\": false\n  }"
```

### Step 4: Parse & Report

The Qwen3.6 model outputs reasoning to `reasoning_content` and the answer to `content` only when `finish_reason: "stop"`. Always extract from `reasoning_content` first:

```bash
curl -s http://127.0.0.1:13305/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '<payload>' | python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data['choices'][0]['message']
reasoning = msg.get('reasoning_content', '')
content = msg.get('content', '')
# reasoning_content always has the full text; content may be empty
result = reasoning.strip() if reasoning.strip() else content.strip()
print(result)
"
```

Then parse and report `result` to the user.

### Annotated Screenshot Workflow (with agent-browser)

When using `agent-browser screenshot --annotate`, the image contains numbered labels [1], [2], [3] that correspond to element refs @e1, @e2, @e3:

```bash
# Get refs + annotated screenshot
agent-browser snapshot -i > /tmp/snapshot.txt
agent-browser screenshot --annotate /tmp/annotated.png

# Read refs
cat /tmp/snapshot.txt
# → heading "Example" [ref=e1]
# → link "Click" [ref=e2]

# Analyze with vision model
SS_BASE64=$(base64 -w 0 /tmp/annotated.png)
curl -s http://127.0.0.1:13305/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d "<payload>"
# → Model response: "Label [1] is the main heading. Label [2] is a blue button labeled 'Click'"
```

## Pitfalls

- **Heavy pages crash/slow the MCP**: YouTube embeds, heavy JS, animations can cause timeouts. Strip media elements before screenshotting.
- **Large base64 payload**: PNG screenshots can exceed 1MB base64. Use JPEG quality 50-60 to keep under 500KB.
- **Viewport too large**: Use `resize_page(width, height)` before screenshotting to ensure the entire page is visible and the image isn't massive.
- **Model cuts off**: Use `max_tokens: 1024` minimum for detailed page analysis.
- **Refs are session-scoped**: Never reuse refs across different `AGENT_BROWSER_SESSION` values.
- **Vision model empty in `content`**: Always extract from `reasoning_content` first, then `content` fallback.

## Verification

- Screenshot file exists and is under 200KB
- Model response is populated (check `reasoning_content` first, then `content`)
- Response finishes with `finish_reason: "stop"` (not `"length"`) — if truncated, retry with `max_tokens: 2048`
- Annotated screenshot labels [1], [2], [3] match refs @e1, @e2, @e3 from snapshot

## Config Notes

### MCP Servers

**agent-browser** (primary browser tool):
```json
{
  "agent-browser": {
    "command": "agent-browser",
    "args": ["mcp", "--tools", "core,network,tabs,state,react,debug"],
    "env": {
      "AGENT_BROWSER_SESSION": "${PI_WORKTREE_ID}",
      "AGENT_BROWSER_IDLE_TIMEOUT_MS": "300000"
    }
  }
}
```

**chrome-devtools-mcp** (diagnostics only, disabled by default):
```json
{
  "chrome-devtools": {
    "command": "chrome-devtools-mcp",
    "args": ["--browserUrl", "http://127.0.0.1:9222"],
    "disabled": "$CHROME_DEVTOOLS_ENABLED"
  }
}
```

Enable diagnostics: `export CHROME_DEVTOOLS_ENABLED=true`

### Security Settings

```bash
# ..env.browser
export AGENT_BROWSER_MAX_OUTPUT="4000"
export AGENT_BROWSER_IDLE_TIMEOUT_MS=300000
```

### Chrome DevTools MCP args

```json
{
  "command": "chrome-devtools-mcp",
  "args": [
    "--browserUrl", "http://127.0.0.1:9222",
    "--screenshotMaxWidth", "1280",
    "--screenshotMaxHeight", "800"
  ]
}
```

### State Persistence

```bash
# Optional: encrypt session data
export AGENT_BROWSER_ENCRYPTION_KEY="your-32-byte-aes-gcm-key-here"

# Restore previous session state
agent-browser --restore open https://example.com
```
