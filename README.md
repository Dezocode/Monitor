# Monitor 🚀
**Complete Development Environment Setup for macOS**

One-command installation script for a complete AI development environment including MCP System, Claude Code CLI, Gemini CLI, LazyVim, Docker, and Ghostty Terminal with semantic protection and high-resolution execution capabilities.

## ✨ **One-Step Install**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dezocode/Monitor/main/install.sh)"
```

**Verify Installation:**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dezocode/Monitor/main/verify-install.sh)"
```

## 🎯 **What This Installs**

### **Core Dependencies**
- ✅ Xcode Command Line Tools
- ✅ Homebrew Package Manager  
- ✅ Python 3.12+ with pip
- ✅ Node.js & npm
- ✅ Git (latest version)
- ✅ GitHub CLI

### **Applications & Tools**
- 👻 **Ghostty Terminal** (built from source)
- 🤖 **Claude Code CLI** (official CLI tool)
- 💎 **Gemini CLI** (Google's AI CLI tool)
- 📝 **LazyVim** (Neovim distribution)
- 🐳 **Docker** (containerization)
- 🔧 **MCP System** (semantic-protected auto-fix)

### **Python Packages**
- `mcp` - Model Context Protocol
- `anthropic` - Claude API
- `docker` - Docker Python API
- `fastapi` - API framework  
- `rich` - Terminal formatting
- `watchdog` - File monitoring
- Development tools: `black`, `mypy`, `pytest`
- AST analysis: `semantic-version`

## 🚀 **Post-Install Usage**

After installation completes:

1. **Restart Terminal** or run `source ~/.zshrc`
2. **Set up Gemini CLI**: `gemini` (follow prompts to login)
3. **Start Docker**: `docker-start` (if needed)
4. **Launch Claude Code**: `claude`
5. **Start MCP System**: `~/mcp-workspace/launch-mcp-system.sh`
6. **Launch LazyVim**: `lazy` or `nvim`

## 📊 **Features Enabled**

- 🛡️ **Semantic Protection** - Prevents code breaking
- 🔬 **High-Resolution Execution** - 165k+ AST nodes analyzed  
- ⚡ **Unlimited Auto-Fix** - Up to 999,999 fixes
- 💬 **Claude Communication** - Real-time feedback
- 🐙 **GitHub Integration** - Automated PR creation

## 🔧 **Quick Commands**

```bash
# MCP System
mcp-cd               # Navigate to MCP system
mcp-scan             # Run version scan
mcp-fix              # Apply auto-fixes  
mcp-demo             # Test semantic catalog
mcp-test             # Launch rapid fix test

# Development Tools
lazy                 # Launch LazyVim
lv                   # LazyVim shortcut
vim/vi               # Aliased to Neovim
docker-start         # Launch Docker
gemini-test          # Test Gemini API connection

# API Testing
export GEMINI_API_KEY="your-key"   # Set Gemini API key
```

## 📂 **Workspace Structure**

```
~/mcp-workspace/
└── mcp-system/           # Main MCP system
    ├── mcp-tools/        # MCP server tools
    ├── scripts/          # Automation scripts  
    ├── src/              # Source code
    └── docs/             # Documentation
```

## ⚡ **System Requirements**

- macOS 10.15+ (Catalina or later)
- 8GB+ RAM recommended
- 5GB+ free disk space
- Internet connection for downloads
- Admin/sudo access for some installations

## 🔒 **Security & Safety**

This script follows security best practices:
- ✅ Environment verification before execution
- ✅ Comprehensive error handling and validation
- ✅ Safe PATH handling with proper escaping
- ✅ Backup creation for modified shell profiles
- ✅ Uses official installation sources only
- ✅ Shellcheck validated for script safety

## 🆘 **Support**

- 🐛 [Issues](https://github.com/Dezocode/Monitor/issues)
- 📖 [MCP System Documentation](https://github.com/Dezocode/mcp-system)

## 🔧 **Troubleshooting**

**Commands not found after installation:**
```bash
# Restart terminal or reload shell configuration
source ~/.zshrc
```

**Homebrew not in PATH:**
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Python packages not found:**
```bash
# Verify Python 3.12 installation
python3.12 --version
# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

**Gemini CLI authentication:**
```bash
# Run gemini and follow the interactive login prompts
gemini
```

---

**Ready to supercharge your development workflow with semantic-protected automation!** 🎉