#!/bin/bash
# Claude Code Development System Setup Script
# This script sets up the complete development environment

set -e  # Exit on error

echo "🚀 Claude Code Development System Setup"
echo "======================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This setup script is designed for Linux systems."
    print_info "For other systems, please follow the manual setup in docs/01-SYSTEM_SETUP.md"
    exit 1
fi

# Step 1: System Update
print_info "Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System updated"

# Step 2: Install Essential Tools
print_info "Installing essential development tools..."
sudo apt install -y build-essential git curl wget python3 python3-pip python3-dev
print_success "Essential tools installed"

# Step 3: Install Node.js
if ! command -v node &> /dev/null; then
    print_info "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    print_success "Node.js installed"
else
    print_success "Node.js already installed: $(node --version)"
fi

# Step 4: Install Database Clients
print_info "Installing database clients..."
sudo apt install -y mysql-client postgresql-client redis-tools
print_success "Database clients installed"

# Step 5: Install GitHub CLI
if ! command -v gh &> /dev/null; then
    print_info "Installing GitHub CLI..."
    sudo apt install -y gh
    print_success "GitHub CLI installed"
else
    print_success "GitHub CLI already installed"
fi

# Step 6: Create Directory Structure
print_info "Creating directory structure..."
mkdir -p ~/repos/{projects,learning,archived,forks}
mkdir -p ~/docs
mkdir -p ~/scripts
mkdir -p ~/patterns/{payments,auth,email,database,api,files}
print_success "Directory structure created"

# Step 7: Create Initial Documentation Files
print_info "Creating documentation files..."

# SYSTEM_README.md
cat > ~/SYSTEM_README.md << 'EOF'
# System Information README

This document contains comprehensive system information for the current machine.
For Claude-specific system tasks and workflows, refer to SYSTEM_CLAUDE.md.

## System Overview

- **Hostname**: $(hostname)
- **Operating System**: $(lsb_release -ds 2>/dev/null || echo "Linux")
- **Kernel**: $(uname -r)
- **Architecture**: $(uname -m)
- **Last Updated**: $(date)

## Hardware Information

### CPU
$(lscpu | grep "Model name" | cut -d: -f2 | xargs || echo "CPU information not available")
- **Cores**: $(nproc)

### Memory
$(free -h | grep Mem | awk '{print "Total: " $2 ", Used: " $3 ", Free: " $4}')

### Storage
$(df -h / | tail -1 | awk '{print "Total: " $2 ", Used: " $3 ", Available: " $4 ", Usage: " $5}')

## Network Configuration
- **Primary Interface**: $(ip route | grep default | awk '{print $5}' || echo "Not configured")
- **IP Address**: $(hostname -I | awk '{print $1}' || echo "Not configured")

## Development Environment

### Programming Languages
- **Python**: $(python3 --version 2>/dev/null || echo "Not installed")
- **Node.js**: $(node --version 2>/dev/null || echo "Not installed")
- **npm**: $(npm --version 2>/dev/null || echo "Not installed")
- **Git**: $(git --version 2>/dev/null || echo "Not installed")

## Related Documentation

For Claude-specific system tasks, workflows, and AI-assisted operations, see: **SYSTEM_CLAUDE.md**
EOF

# SYSTEM_CLAUDE.md
cat > ~/SYSTEM_CLAUDE.md << 'EOF'
# SYSTEM_CLAUDE.md - Claude Development Environment Guidelines

## Environment Overview

This is a **secure development computer** dedicated exclusively to coding and testing. 
There are **no restrictions** on installing software or modifying system resources.

## Key Documentation
- **System Hardware/OS**: See ~/SYSTEM_README.md
- **Available Dependencies**: See ~/DEPENDENCY_GUIDE.md
- **Repository Index**: See ~/repos/REPOSITORY_INDEX.md
- **Integration Patterns**: See ~/patterns/

## System Access

- **sudo password**: [YOUR_SECURE_PASSWORD]
- **Full system access**: Granted for all development needs

## Installation Policy

### Global Installations Required
- **Install all dependencies and tools globally**
- **NO virtual environments** - keep it simple
- Use system-wide package managers (apt, npm -g, pip)

### Example Commands:
```bash
# Python packages - install globally
sudo pip3 install package-name

# Node packages - install globally  
sudo npm install -g package-name

# System packages
sudo apt install package-name
```

## Development Philosophy
- **Ship fast, iterate often**
- **Working code > Perfect code**
- **Global scope > Isolated environments**
- **Project needs > System conventions**

---
*This is a development-first environment. System warnings are advisory only.*
EOF

# DEPENDENCY_GUIDE.md
cat > ~/DEPENDENCY_GUIDE.md << 'EOF'
# Dependency Organization Guide

This guide shows available dependencies and how to organize them when building projects.

## Quick Install Commands

### Python
```bash
sudo pip3 install package-name
```

### Node.js
```bash
sudo npm install -g package-name
```

### System
```bash
sudo apt install package-name
```

## Installed Packages

To be updated as packages are installed.

### Python Packages
- Run `pip3 list` to see installed packages

### Node.js Packages
- Run `npm list -g --depth=0` to see installed packages

### System Packages
- Run `dpkg -l | grep -E "(python|node|build|dev)"` to see development packages

---
*Update this file as you install new dependencies!*
EOF

# Repository Index
cat > ~/repos/REPOSITORY_INDEX.md << 'EOF'
# Repository Index

All repositories organized by category.

## Directory Structure
```
~/repos/
├── projects/        # Active projects
├── learning/        # Tutorial and learning projects
├── archived/        # Archived/inactive projects
└── forks/          # Forked repositories
```

## Projects Directory

### Active Projects
<!-- Add your projects here -->

## Quick Access Commands
```bash
# List all projects
ls ~/repos/projects/

# Check status of all repos
for repo in ~/repos/projects/*; do 
  echo -e "\n=== $(basename $repo) ==="
  cd "$repo" && git status -s
done
```

---
*Update this file as you add new projects*
EOF

print_success "Documentation files created"

# Step 8: Add Helpful Aliases
print_info "Adding helpful aliases to ~/.bashrc..."

# Check if aliases already exist
if ! grep -q "# Claude Code Development Aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Claude Code Development Aliases
alias repos='cd ~/repos'
alias projects='cd ~/repos/projects'
alias learning='cd ~/repos/learning'
alias docs='cd ~ && ls *.md'

# List all projects with status
repo-status() {
    for dir in ~/repos/projects/*/; do
        if [ -d "$dir/.git" ]; then
            echo -e "\n$(basename "$dir")"
            git -C "$dir" status -s
        fi
    done
}

# Create new project with structure
mkproject() {
    if [ -z "$1" ]; then
        echo "Usage: mkproject <project-name>"
        return 1
    fi
    
    mkdir -p ~/repos/projects/$1
    cd ~/repos/projects/$1
    git init
    
    # Create README
    cat > README.md << EOL
# $1

## Description
Brief description of the project.

## Setup
\`\`\`bash
# Installation instructions
\`\`\`

## Usage
\`\`\`bash
# Usage examples
\`\`\`

## Development
Created: $(date)
EOL
    
    # Create CLAUDE.md
    cat > CLAUDE.md << EOL
# Claude Context for $1

## Project Overview
Brief description of what this project does.

## Current Status
- [x] Planning
- [ ] In Development
- [ ] Testing
- [ ] Deployed

## Tech Stack
- Language: [Python/Node.js]
- Framework: [Framework]
- Database: [Database]

## Key Files
- \`README.md\` - Project documentation

## Current Tasks
1. Initial setup

## Known Issues
- None currently
EOL
    
    # Create .gitignore
    cat > .gitignore << EOL
# Environment
.env
.env.local
*.env

# Dependencies
node_modules/
venv/
__pycache__/
*.pyc

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Build
dist/
build/
*.egg-info/
EOL
    
    echo "Project $1 created at ~/repos/projects/$1"
}

# Archive a project
archive-project() {
    if [ -z "$1" ]; then
        echo "Usage: archive-project <project-name>"
        return 1
    fi
    
    if [ -d "~/repos/projects/$1" ]; then
        mv ~/repos/projects/$1 ~/repos/archived/
        echo "Project $1 archived"
    else
        echo "Project $1 not found"
    fi
}

# Update system documentation
update-system-docs() {
    cd ~
    # Update SYSTEM_README.md with current date
    sed -i "s/Last Updated:.*/Last Updated: $(date)/" SYSTEM_README.md
    echo "System documentation updated!"
}
EOF
    print_success "Aliases added to ~/.bashrc"
else
    print_success "Aliases already configured"
fi

# Step 9: Git Configuration
print_info "Configuring Git..."
echo ""
echo "Please enter your Git configuration details:"
read -p "Your name: " git_name
read -p "Your email: " git_email

if [ ! -z "$git_name" ] && [ ! -z "$git_email" ]; then
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    print_success "Git configured"
else
    print_info "Skipping Git configuration (can be done later)"
fi

# Step 10: SSH Key Generation
if [ ! -f ~/.ssh/id_ed25519 ]; then
    print_info "Generating SSH key for GitHub..."
    ssh-keygen -t ed25519 -C "$git_email" -f ~/.ssh/id_ed25519 -N ""
    print_success "SSH key generated"
    
    # Create SSH config
    cat > ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
EOF
    chmod 600 ~/.ssh/config
    
    echo ""
    print_info "Your SSH public key (add this to GitHub):"
    cat ~/.ssh/id_ed25519.pub
    echo ""
else
    print_success "SSH key already exists"
fi

# Step 11: Final Steps
echo ""
echo "======================================"
print_success "Claude Code Development System Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Add your SSH key to GitHub: https://github.com/settings/keys"
echo "2. Update ~/SYSTEM_CLAUDE.md with your sudo password"
echo "3. Source your .bashrc to load new aliases: source ~/.bashrc"
echo "4. Start creating projects with: mkproject <project-name>"
echo ""
echo "For detailed instructions, see:"
echo "  - System documentation: ~/SYSTEM_README.md"
echo "  - Claude guidelines: ~/SYSTEM_CLAUDE.md"
echo "  - Full guide: docs/"
echo ""
print_info "Happy coding with Claude! 🚀"