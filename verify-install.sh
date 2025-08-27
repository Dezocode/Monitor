#!/bin/bash
# Monitor Installation Verification Script
# Run this after the main installation to verify everything works

echo "🧪 Monitor Installation Verification"
echo "===================================="

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Not running on macOS"
    exit 1
fi

echo "✅ Running on macOS $(sw_vers -productVersion)"

# Function to check if command exists and show status
check_command() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" &> /dev/null; then
        echo "✅ $name: $(command -v "$cmd")"
        return 0
    else
        echo "❌ $name: not found"
        return 1
    fi
}

# Function to check if directory exists
check_directory() {
    local dir="$1"
    local name="$2"
    
    if [[ -d "$dir" ]]; then
        echo "✅ $name: $dir"
        return 0
    else
        echo "❌ $name: not found"
        return 1
    fi
}

echo ""
echo "Checking core tools..."
errors=0

check_command "brew" "Homebrew" || ((errors++))
check_command "python3.12" "Python 3.12" || ((errors++))
check_command "node" "Node.js" || ((errors++))
check_command "git" "Git" || ((errors++))
check_command "gh" "GitHub CLI" || ((errors++))
check_command "nvim" "Neovim" || ((errors++))

echo ""
echo "Checking applications..."
check_command "claude" "Claude CLI" || echo "⚠️  Claude CLI: may need setup"
check_command "gemini" "Gemini CLI" || echo "⚠️  Gemini CLI: may need auth"
check_command "docker" "Docker" || echo "⚠️  Docker: may not be running"
check_command "ghostty" "Ghostty" || echo "⚠️  Ghostty: may need manual install"

echo ""
echo "Checking configurations..."
check_directory "$HOME/.config/nvim" "LazyVim config"
check_directory "$HOME/mcp-workspace" "MCP workspace"
check_directory "$HOME/.config/gemini" "Gemini config"

echo ""
echo "Checking Python packages..."
python3.12 -c "
try:
    import mcp; print('✅ MCP Protocol: Ready')
except ImportError:
    print('❌ MCP Protocol: Failed')

try:
    import anthropic; print('✅ Anthropic API: Ready')
except ImportError:
    print('❌ Anthropic API: Failed')
"

echo ""
if [[ $errors -eq 0 ]]; then
    echo "🎉 Installation verification complete - all core tools found!"
else
    echo "⚠️  $errors core tools missing - see troubleshooting in README"
fi

echo ""
echo "Next steps:"
echo "1. Restart terminal: source ~/.zshrc"
echo "2. Setup Gemini: gemini"
echo "3. Launch Claude: claude"
echo "4. Start LazyVim: lazy"