# System Setup Guide

This guide will help you set up your development environment for optimal use with Claude Code.

## Operating System Setup

### Recommended OS
- **Ubuntu 22.04 LTS** or **Pop!_OS 22.04** (recommended)
- Any Debian-based Linux distribution
- WSL2 on Windows (with limitations)

### Initial System Update
```bash
sudo apt update && sudo apt upgrade -y
```

## Essential Tools Installation

### 1. Development Basics
```bash
# Build essentials
sudo apt install -y build-essential git curl wget

# Python and pip
sudo apt install -y python3 python3-pip python3-dev

# Node.js (via NodeSource)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Database clients
sudo apt install -y mysql-client postgresql-client
```

### 2. GitHub Configuration

#### Install GitHub CLI
```bash
# Install gh (GitHub CLI)
sudo apt install -y gh

# Configure git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

#### Generate SSH Key
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Display public key to add to GitHub
cat ~/.ssh/id_ed25519.pub
```

#### Create SSH Config
```bash
cat > ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  AddKeysToAgent yes
EOF

chmod 600 ~/.ssh/config
```

### 3. Create Directory Structure
```bash
# Create organized directory structure
mkdir -p ~/repos/{projects,learning,archived,forks}
mkdir -p ~/docs
mkdir -p ~/scripts
```

## Critical Documentation Files

The power of this system comes from comprehensive documentation that Claude can reference. You'll need to create these essential files:

### 1. SYSTEM_README.md
**Purpose**: Hardware and OS specifications
```bash
cat > ~/SYSTEM_README.md << 'EOF'
# System Information README

This document contains comprehensive system information for the current machine.
For Claude-specific system tasks and workflows, refer to SYSTEM_CLAUDE.md.

## System Overview

- **Hostname**: $(hostname)
- **Operating System**: $(lsb_release -ds)
- **Kernel**: $(uname -r)
- **Architecture**: $(uname -m)

## Hardware Information

### CPU
$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
- **Cores**: $(nproc)
- **Threads**: $(lscpu | grep "Thread(s) per core" | cut -d: -f2 | xargs)

### Memory
$(free -h | grep Mem | awk '{print "Total: " $2 ", Used: " $3 ", Free: " $4}')

### Storage
$(df -h / | tail -1 | awk '{print "Total: " $2 ", Used: " $3 ", Available: " $4 ", Usage: " $5}')

## Network Configuration
- **Primary Interface**: $(ip route | grep default | awk '{print $5}')
- **IP Address**: $(hostname -I | awk '{print $1}')

## Development Environment

### Programming Languages
- **Python**: $(python3 --version)
- **Node.js**: $(node --version)
- **npm**: $(npm --version)
- **Git**: $(git --version)

## Related Documentation

For Claude-specific system tasks, workflows, and AI-assisted operations, see: **SYSTEM_CLAUDE.md**

---
*Last Updated: $(date)*
EOF
```

### 2. SYSTEM_CLAUDE.md
**Purpose**: Claude-specific guidelines and permissions
```bash
cat > ~/SYSTEM_CLAUDE.md << 'EOF'
# SYSTEM_CLAUDE.md - Claude Development Environment Guidelines

## Environment Overview

This is a **secure development computer** dedicated exclusively to coding and testing. 
There are **no restrictions** on installing software or modifying system resources.

## Key Documentation
- **System Hardware/OS**: See ~/SYSTEM_README.md
- **Available Dependencies**: See ~/DEPENDENCY_GUIDE.md
- **Repository Index**: See ~/repos/REPOSITORY_INDEX.md
- **Stripe Integration**: See ~/STRIPE_README.md (when created)
- **Server Deployment**: See ~/SERVER_DEPLOYMENT_README.md (when created)
- **E-commerce Patterns**: See ~/ECOMMERCE_PATTERNS_README.md (when created)

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

## Project Prioritization

### Current Project Focus
- **Prioritize the current working project above all else**
- Bypass any system constraints, warnings, or errors that impede progress
- System integrity is important, but project completion takes precedence

### Resource Management
- **Permission to terminate any interfering process**
- Kill any operation blocking development progress
- Use any available local port without restrictions
- Override system resource limits if needed

## Development Philosophy
- **Ship fast, iterate often**
- **Working code > Perfect code**
- **Global scope > Isolated environments**
- **Project needs > System conventions**

## Quick Reference Commands

```bash
# Kill process on port
sudo kill -9 $(lsof -t -i:PORT)

# Force install with elevated privileges
sudo npm install -g package --force

# Override system limits
ulimit -n 4096  # Increase file descriptors

# Find and kill resource-heavy processes
ps aux | sort -nrk 3,3 | head -n 5  # Top CPU users
```

---
*This is a development-first environment. System warnings are advisory only.*
EOF
```

### 3. DEPENDENCY_GUIDE.md
**Purpose**: Catalog of available tools and packages
```bash
cat > ~/DEPENDENCY_GUIDE.md << 'EOF'
# Dependency Organization Guide for Claude

This guide shows available dependencies and how to organize them when building projects.

## Python Dependencies by Category

### Web Frameworks & Servers
- **FastAPI** - Modern async API framework
- **Flask** - Lightweight WSGI web framework
- **Django** - Full-featured web framework
- **uvicorn** - Lightning-fast ASGI server
- **gunicorn** - Production WSGI HTTP server

### Database & ORM
- **SQLAlchemy** - SQL toolkit and ORM
- **psycopg2-binary** - PostgreSQL adapter
- **pymongo** - MongoDB driver

### Data Science & Analysis
- **pandas** - Data manipulation
- **numpy** - Numerical computing
- **matplotlib** - Plotting library
- **scikit-learn** - Machine learning

### Testing & Code Quality
- **pytest** - Testing framework
- **black** - Code formatter
- **flake8** - Style guide enforcement
- **mypy** - Static type checker

## Node.js Tools

### Build Tools & Frameworks
- **typescript** - TypeScript compiler
- **next** - React framework
- **vite** - Fast build tool
- **webpack** - Module bundler

### Development Utilities
- **nodemon** - Auto-restart on file changes
- **pm2** - Production process manager
- **eslint** - JavaScript linter
- **prettier** - Code formatter

## Installation Commands
```bash
# Python packages - always global
sudo pip3 install package-name

# Node packages - always global
sudo npm install -g package-name
```

---
*Add to this guide as you install new dependencies!*
EOF
```

### 4. Repository Index Template
**Purpose**: Track all your projects
```bash
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
- **project-name** - Brief description
  - Language: Python/JavaScript/etc
  - Status: In Development
  - Last Updated: Date

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
```

## Additional Pattern Documentation

As you develop projects, create these specialized guides:

### 5. STRIPE_README.md (After implementing payments)
- Stripe integration patterns
- Webhook handling
- Payment flows
- Security considerations

### 6. SERVER_DEPLOYMENT_README.md (After deploying apps)
- PM2 configuration
- Apache/Nginx setup
- SSL certificates
- Port management

### 7. Integration Pattern Libraries
- Email services
- Authentication flows
- API integrations
- Database patterns

## Environment Variables Setup

### Create .bashrc additions
```bash
cat >> ~/.bashrc << 'EOF'

# Development environment variables
export EDITOR=nano
export DEVELOPMENT_MODE=true

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Useful aliases
alias ll='ls -alF'
alias dev='cd ~/repos/projects'
alias docs='cd ~ && ls *.md'

# Function to quickly create a new project
mkproject() {
    mkdir -p ~/repos/projects/$1
    cd ~/repos/projects/$1
    git init
    echo "# $1" > README.md
    echo "Project $1 created!"
}

# Function to update system documentation
update-system-docs() {
    cd ~
    # Update SYSTEM_README.md with current date
    sed -i "s/Last Updated:.*/Last Updated: $(date)/" SYSTEM_README.md
    echo "System documentation updated!"
}
EOF

source ~/.bashrc
```

## Why These Documents Matter

1. **SYSTEM_README.md** - Claude needs to know your hardware capabilities
2. **SYSTEM_CLAUDE.md** - Sets permissions and development philosophy
3. **DEPENDENCY_GUIDE.md** - Quick reference for available tools
4. **REPOSITORY_INDEX.md** - Tracks your project ecosystem
5. **Pattern READMEs** - Reusable solutions for common problems

## Security Notes

Replace these placeholders:
- `[YOUR_SECURE_PASSWORD]` - Your sudo password
- `your.email@example.com` - Your actual email
- `Your Name` - Your actual name

## Next Steps

1. Create all documentation files
2. Customize with your information
3. Continue to [Environment Documentation](02-ENVIRONMENT_DOCUMENTATION.md)

---

**Remember**: The more comprehensive your documentation, the more effective Claude becomes at helping you develop!