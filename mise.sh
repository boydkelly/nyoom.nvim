#!/usr/bin/env bash
# 1. Ensure mise is installed
if ! command -v mise &>/dev/null; then
  echo "Mise not found. Installing..."
  curl https://mise.jdx.dev/install.sh | sh
  # Inject mise binary path into current subshell to continue execution
  export PATH="$HOME/.local/share/mise/bin:$PATH"
else
  echo "Mise found. Updating mise..."
  mise self-update --yes
fi

# 2. Update and Install tools
echo "Checking for tool updates and installing missing dependencies..."
# 'upgrade' updates existing tools to the latest version allowed by mise.toml
mise upgrade --yes
# 'install' ensures anything missing from mise.toml is downloaded
mise install --yes

# 3. Finalize the session path
# This makes the shims for the (potentially new) versions available immediately
eval "$(mise activate bash --shims)"

echo "🚀 Environment synced! Mise and all tools are up to date and in your PATH."
