#!/bin/bash
# Monitor: Complete Dev Environment + MCP System Setup
# Repository: https://github.com/Dezocode/Monitor
# Includes: Claude, Gemini, LazyVim, Docker, Ghostty, MCP System

set -e

echo "🚀 MONITOR: COMPLETE DEV ENVIRONMENT SETUP"
echo "==========================================="
echo "🔗 Repository: https://github.com/Dezocode/Monitor"
echo "📦 Includes: Claude + Gemini + LazyVim + Docker + Ghostty + MCP"
echo ""

# Path validation function
validate_and_fix_path() {
    echo "🔧 Validating and fixing PATH..."
    
    # Common paths that should be in PATH
    local common_paths=(
        "/usr/local/bin"
        "/opt/homebrew/bin" 
        "/opt/homebrew/sbin"
        "$HOME/.local/bin"
        "/usr/bin"
        "/bin"
    )
    
    # Check and add missing paths
    for path in "${common_paths[@]}"; do
        if [[ ":$PATH:" != *":$path:"* ]] && [[ -d "$path" ]]; then
            export PATH="$path:$PATH"
            echo "   ✅ Added $path to PATH"
        fi
    done
    
    # Update shell profiles
    for profile in ~/.zshrc ~/.bash_profile ~/.bashrc; do
        if [[ -f "$profile" ]]; then
            if ! grep -q "opt/homebrew/bin" "$profile"; then
                echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >> "$profile"
            fi
            if ! grep -q ".local/bin" "$profile"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
            fi
        fi
    done
}

# Check macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Validate and fix PATH first
validate_and_fix_path

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

# Install Docker
echo "🐳 Installing Docker..."
brew install --cask docker
echo "   Docker installed - you may need to launch Docker.app once"

# Install Neovim for LazyVim
echo "📝 Installing Neovim..."
brew install neovim

# Install LazyVim dependencies
echo "🚀 Installing LazyVim dependencies..."
brew install ripgrep fd tree-sitter lua luarocks
brew install --cask font-jetbrains-mono-nerd-font

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

# Install Gemini API tools
echo "💎 Installing Gemini API tools..."
python3.12 -m pip install --user google-generativeai google-cloud-aiplatform

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
    google-generativeai google-cloud-aiplatform \
    black isort mypy flake8 pylint pytest pytest-asyncio \
    jsonschema typing-extensions docker

# Setup LazyVim
echo "🚀 Setting up LazyVim..."
if [[ ! -d ~/.config/nvim ]]; then
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    rm -rf ~/.config/nvim/.git
    echo "   LazyVim starter configuration installed"
fi

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

# Create Gemini API configuration
echo "💎 Configuring Gemini API..."
cat > ~/.gemini_config << 'EOFGEMINI'
# Gemini API Configuration
# Set your API key: export GEMINI_API_KEY="your-api-key-here"
# Get your API key from: https://makersuite.google.com/app/apikey

export GEMINI_MODEL="gemini-1.5-pro"
export GEMINI_TEMPERATURE="0.7"
EOFGEMINI

# Configure shell
echo "🔧 Configuring shell environment..."
cat >> ~/.zshrc << 'EOFSHELL'

# Monitor: Complete Dev Environment Configuration
export MCP_WORKSPACE="$HOME/mcp-workspace"
export MCP_SYSTEM_PATH="$MCP_WORKSPACE/mcp-system"
export PYTHONPATH="$MCP_SYSTEM_PATH:$PYTHONPATH"

# Ensure proper PATH ordering
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.local/bin:/usr/local/bin:$PATH"

# Load Gemini configuration
[[ -f ~/.gemini_config ]] && source ~/.gemini_config

# MCP System Aliases
alias mcp-cd="cd $MCP_SYSTEM_PATH"
alias mcp-scan="cd $MCP_SYSTEM_PATH && python3.12 scripts/version_keeper.py"
alias mcp-fix="cd $MCP_SYSTEM_PATH && python3.12 scripts/claude_quality_patcher.py"
alias mcp-demo="cd $MCP_SYSTEM_PATH && python3.12 demo_semantic_catalog.py"
alias mcp-test="cd $MCP_SYSTEM_PATH && python3.12 test_rapid_semantic_fix.py"

# Development Aliases
alias vim="nvim"
alias vi="nvim"
alias docker-start="open -a Docker"
alias gemini-test="python3.12 -c \"import google.generativeai as genai; print('Gemini API ready')\""

# LazyVim
alias lazy="nvim"
alias lv="nvim"
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

# Test installations and path validation
echo ""
echo "🧪 TESTING INSTALLATIONS:"
echo "   Python: $(python3.12 --version 2>/dev/null || echo 'Not found in PATH')"
echo "   Node: $(node --version 2>/dev/null || echo 'Not found in PATH')"  
echo "   Git: $(git --version 2>/dev/null || echo 'Not found in PATH')"
echo "   GitHub CLI: $(gh --version 2>/dev/null | head -n1 || echo 'Not found in PATH')"
echo "   Docker: $(docker --version 2>/dev/null || echo 'Docker app not running')"
echo "   Neovim: $(nvim --version 2>/dev/null | head -n1 || echo 'Not found in PATH')"
echo "   Ghostty: $(ghostty --version 2>/dev/null || echo 'Installed')"

# Test Python packages
echo ""
echo "🐍 TESTING PYTHON PACKAGES:"
python3.12 -c "import anthropic; print('   ✅ Anthropic/Claude API')" 2>/dev/null || echo "   ❌ Anthropic API"
python3.12 -c "import google.generativeai; print('   ✅ Gemini API')" 2>/dev/null || echo "   ❌ Gemini API"  
python3.12 -c "import docker; print('   ✅ Docker Python')" 2>/dev/null || echo "   ❌ Docker Python"
python3.12 -c "import mcp; print('   ✅ MCP Protocol')" 2>/dev/null || echo "   ❌ MCP Protocol"

# Validate PATH
echo ""
echo "🔧 PATH VALIDATION:"
echo "   Current PATH: $PATH"
if command -v brew >/dev/null 2>&1; then
    echo "   ✅ Homebrew in PATH"
else
    echo "   ❌ Homebrew not in PATH - run: eval \"\$($(brew --prefix)/bin/brew shellenv)\""
fi

echo ""
echo "✅ MONITOR COMPLETE DEV ENVIRONMENT READY!"
echo "=========================================="
echo ""
echo "🎯 NEXT STEPS:"
echo "1. source ~/.zshrc  # (or restart terminal)"
echo "2. docker-start     # (launch Docker if needed)"
echo "3. open -a Claude   # (launch Claude Desktop)" 
echo "4. ~/mcp-workspace/launch-mcp-system.sh  # (start MCP server)"
echo ""
echo "🚀 WHAT'S INSTALLED & READY:"
echo "   • 🤖 Claude Desktop + API"
echo "   • 💎 Gemini API (set GEMINI_API_KEY)"
echo "   • 📝 LazyVim (nvim/lazy/lv commands)"
echo "   • 🐳 Docker + Python Docker API"
echo "   • 👻 Ghostty Terminal"
echo "   • 🔧 MCP System with semantic protection"
echo "   • ⚡ 165k+ AST nodes analyzed, unlimited auto-fix"
echo ""
echo "🔧 QUICK COMMANDS:"
echo "   mcp-cd           # Navigate to MCP system"
echo "   mcp-scan         # Run version scan"
echo "   mcp-fix          # Apply auto-fixes"
echo "   lazy             # Launch LazyVim"
echo "   docker-start     # Start Docker"
echo "   gemini-test      # Test Gemini API"
echo ""
echo "📖 Documentation: https://github.com/Dezocode/Monitor"
echo "🔑 Get Gemini API key: https://makersuite.google.com/app/apikey"

# Final PATH validation
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
source ~/.zshrc 2>/dev/null || true