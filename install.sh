#!/bin/bash
# LocalPibox Pi Stack — Bootstrap Script
#
# Usage: bash install.sh [path/to/pi/agent]
#
# This script installs the LocalPibox Pi stack configuration:
# 1. Reads settings from this repo's files
# 2. Copies them to the Pi agent directory
# 3. Copies support files to /opt/pi-support/
# 4. Prompts for .env configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_AGENT_DIR="${1:-$HOME/.pi/agent}"

echo "=== LocalPibox Pi Stack Bootstrap ==="
echo ""

# 1. Settings
echo "[1/4] Installing settings..."
cp "$SCRIPT_DIR/settings.json" "$PI_AGENT_DIR/settings.json"
cp "$SCRIPT_DIR/mcp.json" "$PI_AGENT_DIR/mcp.json"
if [ -f "$SCRIPT_DIR/lpb-memory-config.json" ]; then
    cp "$SCRIPT_DIR/lpb-memory-config.json" "$PI_AGENT_DIR/lpb-memory-config.json"
fi
echo "  → settings.json"
echo "  → mcp.json"
echo "  → lpb-memory-config.json (if present)"

# 2. Skills
echo "[2/4] Installing skills..."
mkdir -p "$PI_AGENT_DIR/skills"
for skill_dir in "$SCRIPT_DIR/skills/"*/; do
    skill_name=$(basename "$skill_dir")
    cp "$skill_dir/SKILL.md" "$PI_AGENT_DIR/skills/$skill_name/SKILL.md" 2>/dev/null || true
    mkdir -p "$PI_AGENT_DIR/skills/$skill_name"
    cp "$skill_dir/"* "$PI_AGENT_DIR/skills/$skill_name/" 2>/dev/null || true
    echo "  → skills/$skill_name"
done

# 3. Agents
echo "[3/4] Installing agents..."
mkdir -p "$PI_AGENT_DIR/agents"
for agent_file in "$SCRIPT_DIR/agents/"*; do
    agent_name=$(basename "$agent_file")
    cp "$agent_file" "$PI_AGENT_DIR/agents/$agent_name"
    echo "  → agents/$agent_name"
done

# 4. Support files
echo "[4/4] Installing support files..."
mkdir -p /opt/pi-support
cp -r "$SCRIPT_DIR/support/"* /opt/pi-support/ 2>/dev/null || true
chmod +x /opt/pi-support/bin/*.sh 2>/dev/null || true
echo "  → /opt/pi-support/"

echo ""
echo "=== Configuration Complete ==="
echo ""
echo "Next steps:"
echo "  1. Copy .env.example to .env in your project directory"
echo "  2. Fill in real values (EXA_API_KEY, CONNECTION_TOKEN, etc.)"
echo "  3. Start Pi: pi"
echo ""
echo "Settings:"
echo "  Provider: lemonade"
echo "  Model: Qwen3.6-35B-A3B-MTP-GGUF"
echo "  Thinking: medium"
