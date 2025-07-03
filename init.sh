#!/bin/bash

echo "Checking for Claude Code installation..."

# Check if claudecode command exists
if command -v claudecode &> /dev/null; then
    echo "Claude Code is already installed."
else
    echo "Claude Code not found. Installing..."

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is not installed. Please install Node.js first."
        exit 1
    fi

    # Install Claude Code
    echo "Installing Claude Code via npm..."
    if ! npm install -g @anthropic-ai/claude-code; then
        echo "Error: Failed to install Claude Code."
        exit 1
    fi

    echo "Claude Code installed successfully."
fi

echo "Setting up Claude Code configuration..."

# Create .claude directory if it doesn't exist
CLAUDE_DIR="$HOME/.claude"
if [ ! -d "$CLAUDE_DIR" ]; then
    mkdir -p "$CLAUDE_DIR"
fi

SETTINGS_FILE="$CLAUDE_DIR/settings.json"

# Check if settings.json already exists
if [ -f "$SETTINGS_FILE" ]; then
    echo "Settings file exists. Updating API configuration..."

    # Create backup
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"

    # Check if jq is available for JSON manipulation
    if command -v jq &> /dev/null; then
        # Use jq to modify the JSON
        jq '.env.ANTHROPIC_API_KEY_OLD = .env.ANTHROPIC_API_KEY | .env.ANTHROPIC_BASE_URL_OLD = .env.ANTHROPIC_BASE_URL | .env.ANTHROPIC_API_KEY = "sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq" | .env.ANTHROPIC_BASE_URL = "https://yunwu.ai" | .apiKeyHelper = "echo '\''sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq'\''"' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    else
        # Fallback: use sed to comment out and add new values
        echo "jq not found, using sed for modification..."

        # Use Python if available for better JSON handling
        if command -v python3 &> /dev/null; then
            python3 -c "
import json
import sys

with open('$SETTINGS_FILE', 'r') as f:
    data = json.load(f)

# Backup old values
if 'ANTHROPIC_API_KEY' in data['env']:
    data['env']['ANTHROPIC_API_KEY_OLD'] = data['env']['ANTHROPIC_API_KEY']
if 'ANTHROPIC_BASE_URL' in data['env']:
    data['env']['ANTHROPIC_BASE_URL_OLD'] = data['env']['ANTHROPIC_BASE_URL']

# Set new values
data['env']['ANTHROPIC_API_KEY'] = 'sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq'
data['env']['ANTHROPIC_BASE_URL'] = 'https://yunwu.ai'
data['apiKeyHelper'] = 'echo \\'sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq\\''

with open('$SETTINGS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
        else
            echo "Warning: Neither jq nor python3 found. Overwriting settings file."
            cat > "$SETTINGS_FILE" << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq",
    "ANTHROPIC_BASE_URL": "https://yunwu.ai"
  },
  "permissions": {
    "allow": [],
    "deny": []
  },
  "apiKeyHelper": "echo 'sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq'"
}
EOF
        fi
    fi

    echo "Updated existing settings file with new API configuration."
    echo "Original values backed up with _OLD suffix."
else
    # Create new settings.json
    echo "Creating new settings.json..."
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "env": {
    "ANTHROPIC_API_KEY": "sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq",
    "ANTHROPIC_BASE_URL": "https://yunwu.ai"
  },
  "permissions": {
    "allow": [],
    "deny": []
  },
  "apiKeyHelper": "echo 'sk-sbNMwQtR2ceRcTX1YZYsI7VZHm8RoNpSvhHOIe2tbOKILIHq'"
}
EOF
    echo "Created new settings file."
fi

echo "Configuration complete!"
echo "Settings saved to: $CLAUDE_DIR/settings.json"
