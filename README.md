# Monitor 🚀
**One-Command MCP System Setup for macOS**

Complete installation script for MCP System + Claude Desktop + Ghostty Terminal with semantic protection and high-resolution execution capabilities.

## ✨ **One-Step Install**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dezocode/Monitor/main/install.sh)"
```

## 🎯 **What This Installs**

### **Core Dependencies**
- ✅ Xcode Command Line Tools
- ✅ Homebrew Package Manager  
- ✅ Python 3.12+ with pip
- ✅ Node.js & npm
- ✅ Git (latest version)
- ✅ GitHub CLI

### **Applications**
- 👻 **Ghostty Terminal** (built from source)
- 🤖 **Claude Desktop** (official release)
- 🔧 **MCP System** (semantic-protected auto-fix)

### **Python Packages**
- `mcp` - Model Context Protocol
- `fastapi` - API framework  
- `anthropic` - Claude API
- `rich` - Terminal formatting
- `watchdog` - File monitoring
- Development tools: `black`, `mypy`, `pytest`
- AST analysis: `ast-monitor`, `semantic-version`

## 🚀 **Post-Install Usage**

After installation completes:

1. **Restart Terminal** or run `source ~/.zshrc`
2. **Launch System**: `~/mcp-workspace/launch-mcp-system.sh`
3. **Open Claude Desktop** from Applications
4. **Start Coding** with semantic-protected auto-fix!

## 📊 **Features Enabled**

- 🛡️ **Semantic Protection** - Prevents code breaking
- 🔬 **High-Resolution Execution** - 165k+ AST nodes analyzed  
- ⚡ **Unlimited Auto-Fix** - Up to 999,999 fixes
- 💬 **Claude Communication** - Real-time feedback
- 🐙 **GitHub Integration** - Automated PR creation

## 🔧 **Quick Commands**

```bash
# Navigate to MCP system
mcp-cd

# Run version scan
mcp-scan

# Apply auto-fixes  
mcp-fix --auto-mode --max-fixes=1000

# Test semantic catalog
mcp-demo

# Launch rapid fix test
mcp-test
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

## 🆘 **Support**

- 🐛 [Issues](https://github.com/Dezocode/Monitor/issues)
- 📖 [MCP System Documentation](https://github.com/Dezocode/mcp-system)

---

**Ready to supercharge your development workflow with semantic-protected automation!** 🎉