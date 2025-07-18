# 🔒 Security-Focused DevPod

This branch contains a security research and development environment based on the r-mcpsec configuration.

## 🚀 Quick Start with devpod.sh

```bash
devpod up https://github.com/jedarden/agentists-quickstart --branch workspace/security
```

## 📦 What's Included

- **🖼️ Base Image**: Node.js 20 on Debian Bullseye
- **🔤 Language Support**: JavaScript/Node.js development environment
- **🛠️ Development Tools** (auto-installed on container creation):
  - tmux: Terminal multiplexer for managing multiple sessions
  - claude-code: Anthropic's official CLI for Claude
  - GitHub CLI (gh): Command-line interface for GitHub
- **🧬 VS Code Extensions**:
  - Markdown Mermaid: Create diagrams in Markdown
  - Markdown Preview Enhanced: Advanced Markdown preview features
  - Claude Code: Anthropic's official VS Code extension for Claude
  - Claude Code Extension: Enhanced Claude Code cost tracking and features

## ✨ Features

- Port 8282 forwarded with auto-notification
- Latest npm automatically installed
- Yarn package manager pre-configured
- Optimized for security research workflows

## 🌐 Port Configuration

- **🔌 Port 8282**: Labeled as "Hello Remote World"
- Auto-forward notifications enabled

## 🔨 Post-Create Setup

The following commands run automatically after container creation:
- Installs development tools (tmux, claude-code, GitHub CLI)
- Updates npm to the latest version
- Runs `yarn install` to install project dependencies

## 📋 Requirements

- [DevPod CLI](https://devpod.sh/docs/getting-started/install)
- Docker Desktop or Docker Engine
- Node.js project with package.json (for yarn install)

## 🔧 Manual VS Code Usage

If you prefer to use VS Code directly:

1. Clone this branch: `git clone -b workspace/security https://github.com/jedarden/agentists-quickstart`
2. Open in VS Code
3. Install the Dev Containers extension
4. Click "Reopen in Container" when prompted

## 📚 Learn More

For more information about the Agentists project, visit the [main branch](https://github.com/jedarden/agentists-quickstart).