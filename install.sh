#!/bin/bash
# Monitor: Complete Dev Environment + MCP System Setup
# Repository: https://github.com/Dezocode/Monitor
# Includes: Claude, Gemini, LazyVim, Docker, Ghostty, MCP System
# Version: 1.2.0 - Enhanced Safety & Speed

set -euo pipefail  # Enhanced error handling

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Track installation progress
INSTALLED_TOOLS=()
INSTALLATION_PATHS=()

track_installation() {
    INSTALLED_TOOLS+=("$1")
    INSTALLATION_PATHS+=("$2")
    log_success "$1 installed at: $2"
}

echo "🚀 MONITOR: COMPLETE DEV ENVIRONMENT SETUP"
echo "==========================================="
echo "🔗 Repository: https://github.com/Dezocode/Monitor"
echo "📦 Includes: Claude + Gemini + LazyVim + Docker + Ghostty + MCP"
echo "⏱️  Estimated time: 10-15 minutes"
echo ""

# Enhanced PATH validation with safety checks
validate_and_fix_path() {
    log_info "Validating and fixing PATH..."
    
    # Common paths that should be in PATH
    local common_paths=(
        "/opt/homebrew/bin" 
        "/opt/homebrew/sbin"
        "/usr/local/bin"
        "$HOME/.local/bin"
        "/usr/bin"
        "/bin"
    )
    
    # Check and add missing paths (temporary for this session)
    for path in "${common_paths[@]}"; do
        if [[ -d "$path" ]] && [[ ":$PATH:" != *":$path:"* ]]; then
            export PATH="$path:$PATH"
            log_success "Added $path to current session PATH"
        fi
    done
    
    # Update shell profiles safely
    for profile in ~/.zshrc ~/.bash_profile ~/.bashrc; do
        if [[ -f "$profile" ]]; then
            # Create backup
            cp "$profile" "${profile}.monitor-backup" || true
            
            # Add Homebrew paths if not present
            if ! grep -q "/opt/homebrew/bin" "$profile" 2>/dev/null; then
                echo 'export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"' >> "$profile"
                log_success "Added Homebrew paths to $profile"
            fi
            
            # Add local bin path if not present
            if ! grep -q "\$HOME/.local/bin" "$profile" 2>/dev/null; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$profile"
                log_success "Added local bin path to $profile"
            fi
        fi
    done
}

# Safe command execution with logging
safe_brew_install() {
    local package="$1"
    local display_name="${2:-$package}"
    
    if command -v "$package" &> /dev/null; then
        log_warning "$display_name already installed, skipping"
        track_installation "$display_name" "$(command -v "$package")"
        return 0
    fi
    
    log_info "Installing $display_name..."
    if brew install "$package" &>/dev/null; then
        local install_path
        install_path=$(command -v "$package" 2>/dev/null || echo "/opt/homebrew/bin/$package")
        track_installation "$display_name" "$install_path"
    else
        log_error "Failed to install $display_name"
        return 1
    fi
}

# Safe cask installation
safe_brew_cask_install() {
    local package="$1"
    local display_name="${2:-$package}"
    local app_path="/Applications/${display_name}.app"
    
    if [[ -d "$app_path" ]]; then
        log_warning "$display_name already installed, skipping"
        track_installation "$display_name" "$app_path"
        return 0
    fi
    
    log_info "Installing $display_name..."
    if brew install --cask "$package" &>/dev/null; then
        track_installation "$display_name" "$app_path"
    else
        log_error "Failed to install $display_name"
        return 1
    fi
}

# System compatibility check
if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is for macOS only"
    exit 1
fi

log_info "macOS detected: $(sw_vers -productVersion)"

# Validate and fix PATH first
validate_and_fix_path

# Install Xcode Command Line Tools
log_info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    log_warning "Xcode Command Line Tools not found - installing..."
    xcode-select --install
    log_warning "Please complete Xcode installation and re-run:"
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Dezocode/Monitor/main/install.sh)\""
    exit 1
else
    track_installation "Xcode Command Line Tools" "$(xcode-select -p)"
fi

# Install/Update Homebrew
log_info "Setting up Homebrew package manager..."
if ! command -v brew &> /dev/null; then
    log_info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
    
    # Setup Homebrew environment
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        track_installation "Homebrew" "/opt/homebrew/bin/brew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        track_installation "Homebrew" "/usr/local/bin/brew"
    fi
else
    track_installation "Homebrew" "$(command -v brew)"
fi

log_info "Updating Homebrew (silent)..."
brew update &>/dev/null || log_warning "Homebrew update failed (continuing anyway)"

# Install core development tools
log_info "Installing core development tools..."
safe_brew_install "python@3.12" "Python 3.12"
safe_brew_install "node" "Node.js" 
safe_brew_install "git" "Git"
safe_brew_install "gh" "GitHub CLI"

# Install containerization
log_info "Installing Docker..."
safe_brew_cask_install "docker" "Docker"

# Install editor and dependencies
log_info "Installing Neovim and LazyVim dependencies..."
safe_brew_install "neovim" "Neovim"
safe_brew_install "ripgrep" "Ripgrep"
safe_brew_install "fd" "fd (find alternative)"
safe_brew_install "tree-sitter" "Tree-sitter"
safe_brew_install "lua" "Lua"
safe_brew_install "luarocks" "LuaRocks"

log_info "Installing development fonts..."
safe_brew_cask_install "font-jetbrains-mono-nerd-font" "JetBrains Mono Nerd Font"

# Install Ghostty Terminal
log_info "Installing Ghostty Terminal..."
if command -v ghostty &> /dev/null; then
    log_warning "Ghostty already installed, skipping"
    track_installation "Ghostty" "$(command -v ghostty)"
else
    log_info "Installing Zig compiler for Ghostty..."
    safe_brew_install "zig" "Zig"
    
    log_info "Building Ghostty from source (this may take a few minutes)..."
    cd /tmp
    if [[ -d "ghostty" ]]; then
        rm -rf ghostty
    fi
    
    if git clone https://github.com/mitchellh/ghostty.git &>/dev/null; then
        cd ghostty
        if zig build -Doptimize=ReleaseFast &>/dev/null; then
            if sudo cp zig-out/bin/ghostty /usr/local/bin/ &>/dev/null; then
                track_installation "Ghostty" "/usr/local/bin/ghostty"
            else
                log_error "Failed to install Ghostty binary"
            fi
        else
            log_error "Failed to build Ghostty"
        fi
        cd /tmp && rm -rf ghostty
    else
        log_error "Failed to clone Ghostty repository"
    fi
fi

# Install Claude Desktop
log_info "Installing Claude Desktop..."
if [[ -d "/Applications/Claude.app" ]]; then
    log_warning "Claude Desktop already installed, skipping"
    track_installation "Claude Desktop" "/Applications/Claude.app"
else
    cd /tmp
    if curl -L -o "Claude.dmg" "https://claude.ai/download/mac" &>/dev/null; then
        if hdiutil attach "Claude.dmg" -quiet &>/dev/null; then
            if cp -R "/Volumes/Claude/Claude.app" "/Applications/" &>/dev/null; then
                track_installation "Claude Desktop" "/Applications/Claude.app"
                hdiutil detach "/Volumes/Claude" -quiet &>/dev/null || true
                rm -f "Claude.dmg"
            else
                log_error "Failed to copy Claude.app to Applications"
            fi
        else
            log_error "Failed to mount Claude.dmg"
        fi
    else
        log_error "Failed to download Claude Desktop"
    fi
fi

# Create workspace
echo "📂 Setting up workspace..."
mkdir -p ~/mcp-workspace
cd ~/mcp-workspace

# Clone MCP system
echo "📥 Cloning MCP System..."
git clone https://github.com/Dezocode/mcp-system.git
cd mcp-system

# Install Python packages
log_info "Installing Python packages (this may take a few minutes)..."
python3.12 -m pip install --upgrade pip --user &>/dev/null

# Install packages in batches for better error handling
log_info "Installing core MCP and API packages..."
if python3.12 -m pip install --user mcp anthropic openai google-generativeai google-cloud-aiplatform &>/dev/null; then
    log_success "Core AI APIs installed"
else
    log_error "Failed to install some AI API packages"
fi

log_info "Installing development frameworks..."
if python3.12 -m pip install --user fastapi uvicorn pydantic aiofiles click rich watchdog &>/dev/null; then
    log_success "Development frameworks installed"
else
    log_error "Failed to install some development packages"
fi

log_info "Installing development tools..."
if python3.12 -m pip install --user black isort mypy flake8 pylint pytest pytest-asyncio &>/dev/null; then
    log_success "Development tools installed"  
else
    log_error "Failed to install some development tools"
fi

log_info "Installing utility packages..."
if python3.12 -m pip install --user psutil gitpython semantic-version jsonschema typing-extensions docker &>/dev/null; then
    log_success "Utility packages installed"
else
    log_error "Failed to install some utility packages"
fi

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

# Enhanced testing and validation
echo ""
log_info "Running comprehensive installation tests..."

# Test core tools
test_tool() {
    local tool="$1"
    local command="$2"
    local expected_pattern="$3"
    
    if command -v "$tool" &> /dev/null; then
        local version_output
        version_output=$($command 2>/dev/null | head -n1 || echo "unknown version")
        if [[ -n "$expected_pattern" ]] && [[ $version_output =~ $expected_pattern ]]; then
            log_success "$tool: $version_output"
        else
            log_success "$tool: installed at $(command -v "$tool")"
        fi
    else
        log_error "$tool: not found in PATH"
    fi
}

echo ""
echo "🧪 INSTALLATION VERIFICATION:"
echo "================================"

test_tool "python3.12" "python3.12 --version" "Python 3.12"
test_tool "node" "node --version" "v"
test_tool "git" "git --version" "git version"
test_tool "gh" "gh --version" "gh version"
test_tool "nvim" "nvim --version" "NVIM"
test_tool "docker" "docker --version" "Docker version"
test_tool "ghostty" "ghostty --version" ""

# Test Python packages
echo ""
log_info "Testing Python packages..."
python3.12 -c "
try:
    import anthropic; print('✅ Anthropic/Claude API: Ready')
except ImportError:
    print('❌ Anthropic API: Failed')

try:
    import google.generativeai; print('✅ Gemini API: Ready') 
except ImportError:
    print('❌ Gemini API: Failed')

try:
    import docker; print('✅ Docker Python API: Ready')
except ImportError:
    print('❌ Docker Python API: Failed')

try:
    import mcp; print('✅ MCP Protocol: Ready')
except ImportError:
    print('❌ MCP Protocol: Failed')
"

# Validate applications
echo ""
log_info "Validating installed applications..."
[[ -d "/Applications/Claude.app" ]] && log_success "Claude Desktop: /Applications/Claude.app" || log_error "Claude Desktop: not found"
[[ -d "/Applications/Docker.app" ]] && log_success "Docker Desktop: /Applications/Docker.app" || log_error "Docker Desktop: not found"
[[ -d ~/.config/nvim ]] && log_success "LazyVim config: ~/.config/nvim" || log_warning "LazyVim config: not found"

# PATH validation
echo ""
log_info "PATH validation results:"
echo "Current PATH: $PATH"
if command -v brew >/dev/null 2>&1; then
    log_success "Homebrew is accessible in PATH"
else
    log_error "Homebrew not in PATH - run: eval \"\$(brew --prefix)/bin/brew shellenv\""
fi

# Installation Summary
echo ""
echo "📋 INSTALLATION SUMMARY:"
echo "========================="
echo "Total tools installed: ${#INSTALLED_TOOLS[@]}"
echo ""

for i in "${!INSTALLED_TOOLS[@]}"; do
    printf "%-25s %s\n" "${INSTALLED_TOOLS[$i]}:" "${INSTALLATION_PATHS[$i]}"
done

echo ""
log_success "MONITOR COMPLETE DEV ENVIRONMENT READY!"
echo "=========================================="
echo ""
echo "🎯 IMMEDIATE NEXT STEPS:"
echo "1. source ~/.zshrc  # (or restart terminal)"
echo "2. export GEMINI_API_KEY=\"your-api-key\"  # (get from makersuite.google.com)"
echo "3. docker-start     # (launch Docker if needed)"
echo "4. open -a Claude   # (launch Claude Desktop)" 
echo "5. ~/mcp-workspace/launch-mcp-system.sh  # (start MCP server)"
echo ""
echo "🚀 WHAT'S NOW AVAILABLE:"
echo "   • 🤖 Claude Desktop + Anthropic API"
echo "   • 💎 Gemini API (Google AI)"
echo "   • 📝 LazyVim (modern Neovim)"
echo "   • 🐳 Docker + containerization"
echo "   • 👻 Ghostty Terminal"
echo "   • 🔧 MCP System with semantic protection"
echo "   • ⚡ 165k+ AST nodes analyzed, unlimited auto-fix"
echo ""
echo "🔧 ESSENTIAL COMMANDS:"
echo "   lazy             # Launch LazyVim editor"
echo "   mcp-cd           # Navigate to MCP system"
echo "   mcp-scan         # Run comprehensive code scan"
echo "   mcp-fix          # Apply automatic fixes"
echo "   docker-start     # Launch Docker Desktop"
echo "   gemini-test      # Test Gemini API connection"
echo ""
echo "📚 RESOURCES:"
echo "   • Documentation: https://github.com/Dezocode/Monitor"
echo "   • MCP System: https://github.com/Dezocode/mcp-system"
echo "   • Gemini API Key: https://makersuite.google.com/app/apikey"
echo "   • LazyVim Docs: https://lazyvim.org"
echo ""

# Final setup
log_info "Finalizing environment setup..."
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
source ~/.zshrc 2>/dev/null || true

echo "🎉 Setup complete! Restart your terminal to use all features."