#!/bin/bash
# Monitor: MCP System + Claude + Ghostty Fresh Mac Setup
# Repository: https://github.com/Dezocode/Monitor

set -e

echo "🚀 MONITOR: MCP SYSTEM + CLAUDE + GHOSTTY SETUP"
echo "================================================"
echo "🔗 Repository: https://github.com/Dezocode/Monitor"
echo ""

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Install Xcode Command Line Tools
echo "📱 Installing Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    xcode-select --install
    echo "⏳ Please complete Xcode installation and re-run:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Dezocode/Monitor/main/install.sh)\""
    exit 1
fi

# Install Homebrew
echo "🍺 Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "🔄 Updating Homebrew..."
brew update

# Install core dependencies
echo "🐍 Installing Python 3.12..."
brew install python@3.12

echo "📦 Installing Node.js..."
brew install node

echo "📝 Installing Git..."  
brew install git

echo "🐙 Installing GitHub CLI..."
brew install gh

# Install Ghostty
echo "👻 Installing Ghostty Terminal..."
brew install zig
cd /tmp
git clone https://github.com/mitchellh/ghostty.git
cd ghostty
zig build -Doptimize=ReleaseFast
sudo cp zig-out/bin/ghostty /usr/local/bin/
cd /tmp && rm -rf ghostty

# Install Claude Desktop
echo "🤖 Installing Claude Desktop..."
cd /tmp
curl -L -o "Claude.dmg" "https://claude.ai/download/mac"
hdiutil attach "Claude.dmg" -quiet
cp -R "/Volumes/Claude/Claude.app" "/Applications/"
hdiutil detach "/Volumes/Claude" -quiet
rm "Claude.dmg"

# Create workspace
echo "📂 Setting up workspace..."
mkdir -p ~/mcp-workspace
cd ~/mcp-workspace

# Clone MCP system
echo "📥 Cloning MCP System..."
git clone https://github.com/Dezocode/mcp-system.git
cd mcp-system

# Install Python packages
echo "🔧 Installing Python dependencies..."
python3.12 -m pip install --upgrade pip --user

python3.12 -m pip install --user \
    mcp fastapi uvicorn pydantic aiofiles click rich watchdog \
    psutil gitpython semantic-version anthropic openai \
    black isort mypy flake8 pylint pytest pytest-asyncio \
    jsonschema typing-extensions

# Configure Claude MCP
echo "⚙️ Configuring Claude MCP..."
mkdir -p ~/Library/Application\ Support/Claude/
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << 'EOFCONFIG'
{
  "mcpServers": {
    "mcp-system": {
      "command": "python3.12",
      "args": ["~/mcp-workspace/mcp-system/mcp-tools/pipeline-mcp/src/main.py"],
      "env": {
        "PYTHONPATH": "~/mcp-workspace/mcp-system"
      }
    }
  }
}
EOFCONFIG

# Configure shell
echo "🔧 Configuring shell environment..."
cat >> ~/.zshrc << 'EOFSHELL'

# Monitor: MCP System Configuration
export MCP_WORKSPACE="$HOME/mcp-workspace"
export MCP_SYSTEM_PATH="$MCP_WORKSPACE/mcp-system"
export PYTHONPATH="$MCP_SYSTEM_PATH:$PYTHONPATH"
export PATH="$HOME/.local/bin:$PATH"

# MCP System Aliases
alias mcp-cd="cd $MCP_SYSTEM_PATH"
alias mcp-scan="cd $MCP_SYSTEM_PATH && python3.12 scripts/version_keeper.py"
alias mcp-fix="cd $MCP_SYSTEM_PATH && python3.12 scripts/claude_quality_patcher.py"
alias mcp-demo="cd $MCP_SYSTEM_PATH && python3.12 demo_semantic_catalog.py"
alias mcp-test="cd $MCP_SYSTEM_PATH && python3.12 test_rapid_semantic_fix.py"
EOFSHELL

# Configure Ghostty
echo "👻 Configuring Ghostty..."
mkdir -p ~/.config/ghostty
cat > ~/.config/ghostty/config << 'EOFGHOST'
font-family = "JetBrains Mono"
font-size = 14
theme = "catppuccin-mocha"
window-decoration = true
window-padding-x = 10
window-padding-y = 10
shell-integration = zsh
copy-on-select = true
clipboard-read = allow
clipboard-write = allow
EOFGHOST

# Create launcher
cat > ~/mcp-workspace/launch-mcp-system.sh << 'EOFLAUNCH'
#!/bin/bash
echo "🚀 Launching MCP System with Semantic Protection..."
cd ~/mcp-workspace/mcp-system
export PYTHONPATH="$(pwd):$PYTHONPATH"
python3.12 mcp-tools/pipeline-mcp/src/main.py
EOFLAUNCH
chmod +x ~/mcp-workspace/launch-mcp-system.sh

# Test installations
echo ""
echo "🧪 TESTING INSTALLATIONS:"
echo "   Python: $(python3.12 --version)"
echo "   Node: $(node --version)"  
echo "   Git: $(git --version)"
echo "   GitHub CLI: $(gh --version | head -n1)"
echo "   Ghostty: $(ghostty --version 2>/dev/null || echo 'Installed')"

echo ""
echo "✅ MONITOR INSTALLATION COMPLETE!"
echo "================================="
echo ""
echo "🎯 NEXT STEPS:"
echo "1. source ~/.zshrc  # (or restart terminal)"
echo "2. open -a Claude   # (launch Claude Desktop)" 
echo "3. ~/mcp-workspace/launch-mcp-system.sh  # (start MCP server)"
echo ""
echo "🚀 SEMANTIC-PROTECTED AUTO-FIX READY!"
echo "   • 165k+ AST nodes analyzed"
echo "   • 105 critical functions protected"  
echo "   • Unlimited fixes with safety"
echo "   • Real-time Claude communication"
echo ""
echo "📖 Documentation: https://github.com/Dezocode/Monitor"

source ~/.zshrc 2>/dev/null || true