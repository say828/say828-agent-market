#!/bin/bash
set -e

REPO="say828/say828-agent-market"
INSTALL_DIR="$HOME/.local/bin"

case "$(uname -s)" in
    Darwin) os="macos" ;;
    Linux)  os="linux" ;;
    *)      echo "Unsupported OS. Use Windows installer instead." >&2; exit 1 ;;
esac

case "$(uname -m)" in
    x86_64|amd64)   arch="x64" ;;
    arm64|aarch64)  arch="arm64" ;;
    *)              echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

binary_name="claude-orchestrator-${os}-${arch}"

echo "Fetching latest version..."
latest_tag=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep '"tag_name"' | cut -d'"' -f4)

if [ -z "$latest_tag" ]; then
    echo "Failed to fetch latest version" >&2
    exit 1
fi

echo "Installing claude-orchestrator ${latest_tag}..."

binary_url="https://github.com/${REPO}/releases/download/${latest_tag}/${binary_name}"

mkdir -p "$INSTALL_DIR"

tmp_file=$(mktemp)
echo "Downloading ${binary_url}..."
curl -fsSL -o "$tmp_file" "$binary_url"

mv "$tmp_file" "$INSTALL_DIR/claude-orchestrator"
chmod +x "$INSTALL_DIR/claude-orchestrator"

echo ""
echo "claude-orchestrator ${latest_tag} installed to ${INSTALL_DIR}/claude-orchestrator"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "${INSTALL_DIR} is not in your PATH. Add it with:"
    echo ""

    case "$SHELL" in
        */zsh)  shell_config="~/.zshrc" ;;
        */bash) shell_config="~/.bashrc" ;;
        *)      shell_config="your shell config" ;;
    esac

    echo "  echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ${shell_config}"
    echo "  source ${shell_config}"
fi

echo ""
echo "=========================================="
echo "  INSTALLATION COMPLETE!"
echo "=========================================="
echo ""
echo "Install the Claude Code plugin:"
echo "  /plugin marketplace add say828/say828-agent-market"
echo "  /plugin install claude-orchestrator@say828-agent-market"
echo ""
