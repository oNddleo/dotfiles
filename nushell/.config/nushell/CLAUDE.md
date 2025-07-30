# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains Nushell configuration files for a personal dotfiles setup. The main configuration is split between `config.nu` (shell behavior and appearance) and `env.nu` (environment variables and PATH setup).

## Commands

Since this is a configuration repository, there are no build or test commands. Changes are applied by:

- Restarting Nushell or running `source config.nu` to reload configuration
- For environment changes: `source env.nu` or restart shell
- To validate Nushell syntax: `nu --check config.nu` or `nu --check env.nu`

Installation commands from README.md:
```bash
# Install Nushell via Homebrew
brew install nushell

# Set as default shell
echo '/opt/homebrew/bin/nu' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/nu

# Create config directories
mkdir -p ~/.config/nushell/{scripts,completions,plugins}
```

## Configuration Architecture

### Core Files

- **config.nu**: Main configuration file containing:
  - Color themes and syntax highlighting (`$env.config.color_config`)
  - Shell behavior (completion, history, key bindings)
  - Starship prompt integration
  - Custom aliases and functions
  - Table display and error formatting

- **env.nu**: Environment setup containing:
  - PATH configuration with Homebrew, Cargo, Go, Node.js paths
  - Development tool environment variables (EDITOR, GOPATH, CARGO_HOME)
  - Homebrew integration for both Intel and Apple Silicon Macs
  - Starship shell integration
  - Certificate bundle paths for various tools

### Key Configuration Patterns

- **Conditional Path Addition**: Paths are only added if they exist (`where { |p| $p | path exists }`)
- **Cross-platform Homebrew Support**: Detects both `/opt/homebrew` (Apple Silicon) and `/usr/local` (Intel)
- **Tool Integration**: Starship prompt, FZF fuzzy finder, development tools
- **Modern CLI Aliases**: `rg` for grep, `bat` for cat, `fd` for find, `procs` for ps

### Custom Functions

- `git-cleanup`: Removes merged git branches
- `mkcd`: Creates directory and navigates to it
- `weather`: Fetches weather information via wttr.in

### Directory Structure

```
.config/nushell/
├── config.nu          # Main shell configuration
├── env.nu             # Environment variables and PATH
├── scripts/           # Custom Nushell scripts (empty)
├── completions/       # Tab completion scripts (empty) 
└── plugins/           # Nushell plugins directory
```

## Development Notes

- This configuration uses Nushell version 0.106.0 syntax
- Emacs-style key bindings are configured by default
- The configuration includes extensive color theming and shell integration
- SSL certificate paths are configured for various development tools
- Environment variables are loaded from `~/.env` if present