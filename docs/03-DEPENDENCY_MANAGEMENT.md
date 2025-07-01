# Dependency Management Guide

This guide outlines the philosophy and practice of global dependency management for Claude Code development.

## Core Philosophy: Global Over Virtual

### Why Global?
1. **Simplicity**: No juggling virtual environments
2. **Speed**: Claude can immediately use any tool
3. **Clarity**: One source of truth for dependencies
4. **Efficiency**: No context switching between environments

### The Trade-off
We prioritize development speed over isolation. This approach works because:
- This is a dedicated development machine
- We maintain comprehensive documentation
- We can always clean and reinstall if needed

## Setting Up Global Dependencies

### Python Dependencies

#### Initial Setup
```bash
# Ensure pip is up to date
sudo pip3 install --upgrade pip

# Install essential development tools
sudo pip3 install \
    black \
    flake8 \
    mypy \
    pytest \
    ipython \
    jupyter \
    pipenv  # For reading Pipfiles, not creating them
```

#### Web Development Stack
```bash
# Frameworks
sudo pip3 install \
    fastapi \
    flask \
    django \
    streamlit \
    gradio

# Servers and tools
sudo pip3 install \
    uvicorn \
    gunicorn \
    celery \
    redis \
    requests \
    httpx

# Database
sudo pip3 install \
    sqlalchemy \
    psycopg2-binary \
    pymongo \
    alembic
```

#### Data Science Stack
```bash
# Core libraries
sudo pip3 install \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    plotly

# Deep learning (choose based on hardware)
sudo pip3 install torch torchvision  # PyTorch
# OR
sudo pip3 install tensorflow  # TensorFlow
```

### Node.js Dependencies

#### Essential Tools
```bash
# Package managers and build tools
sudo npm install -g \
    yarn \
    pnpm \
    typescript \
    ts-node \
    nodemon

# Frameworks
sudo npm install -g \
    next \
    create-next-app \
    express-generator \
    @angular/cli \
    @vue/cli

# Development tools
sudo npm install -g \
    eslint \
    prettier \
    webpack \
    vite \
    parcel
```

#### Utility Packages
```bash
# HTTP and API tools
sudo npm install -g \
    http-server \
    json-server \
    concurrently \
    pm2

# Testing
sudo npm install -g \
    jest \
    mocha \
    cypress
```

### System-Level Dependencies

#### Development Libraries
```bash
# Database clients
sudo apt install -y \
    mysql-client \
    postgresql-client \
    redis-tools \
    mongodb-clients

# Build tools
sudo apt install -y \
    cmake \
    autoconf \
    automake \
    libtool

# Image processing
sudo apt install -y \
    imagemagick \
    ffmpeg \
    graphicsmagick
```

## Dependency Documentation

### Creating Your DEPENDENCY_GUIDE.md

```bash
#!/bin/bash
# generate-dependency-guide.sh

cat > ~/DEPENDENCY_GUIDE.md << 'EOF'
# Installed Dependencies

Generated: $(date)

## Python Packages
\`\`\`
$(pip3 list --format=columns)
\`\`\`

## Node.js Global Packages
\`\`\`
$(npm list -g --depth=0)
\`\`\`

## System Packages (Development Related)
\`\`\`
$(dpkg -l | grep -E "(python|node|build|dev)" | awk '{print $2}' | sort)
\`\`\`

## Quick Install Commands

### Add Python Package
\`\`\`bash
sudo pip3 install package-name
\`\`\`

### Add Node Package
\`\`\`bash
sudo npm install -g package-name
\`\`\`

### Add System Package
\`\`\`bash
sudo apt install package-name
\`\`\`
EOF

echo "Dependency guide generated!"
```

### Tracking Dependencies by Project Type

Create a reference for common project stacks:

```markdown
# Project Type Dependencies

## FastAPI Backend
- fastapi
- uvicorn
- sqlalchemy
- alembic
- pydantic
- python-jose[cryptography]
- passlib[bcrypt]
- python-multipart

## Next.js Frontend
- next (global)
- typescript (global)
- eslint (global)
- prettier (global)

## Data Analysis Project
- pandas
- numpy
- matplotlib
- jupyter
- seaborn
- plotly

## Web Scraping
- scrapy
- beautifulsoup4
- selenium
- playwright
- requests
- lxml
```

## Managing Dependencies

### Regular Maintenance

#### Weekly Tasks
```bash
# Update Python packages
sudo pip3 list --outdated
# Update selective packages
sudo pip3 install --upgrade package-name

# Update Node packages
npm outdated -g
# Update selective packages
sudo npm update -g package-name
```

#### Monthly Tasks
```bash
# System update
sudo apt update && sudo apt upgrade

# Clean up unused packages
sudo apt autoremove
sudo apt autoclean

# Update pip itself
sudo pip3 install --upgrade pip
```

### Handling Conflicts

#### Python Version Conflicts
```bash
# If a package requires specific Python version
# Install Python version manager
sudo apt install python3.11 python3.11-venv

# Create alias for specific version
alias python3.11="/usr/bin/python3.11"
```

#### Node Version Conflicts
```bash
# Install nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Install specific Node version
nvm install 18
nvm use 18
```

### Dependency Backup

Create a backup of all installed packages:

```bash
#!/bin/bash
# backup-dependencies.sh

mkdir -p ~/dependency-backups

# Backup Python packages
pip3 freeze > ~/dependency-backups/python-packages-$(date +%Y%m%d).txt

# Backup Node packages
npm list -g --depth=0 > ~/dependency-backups/node-packages-$(date +%Y%m%d).txt

# Backup apt packages
dpkg --get-selections > ~/dependency-backups/apt-packages-$(date +%Y%m%d).txt

echo "Dependencies backed up!"
```

### Restore from Backup
```bash
# Restore Python packages
sudo pip3 install -r ~/dependency-backups/python-packages-YYYYMMDD.txt

# Restore apt packages
sudo dpkg --set-selections < ~/dependency-backups/apt-packages-YYYYMMDD.txt
sudo apt-get dselect-upgrade
```

## Best Practices

### 1. Document Everything
Every time you install a package, add it to DEPENDENCY_GUIDE.md with:
- Package name
- Version (if specific)
- Purpose
- Install command

### 2. Group Related Packages
Install related packages together:
```bash
# Good - Install web stack together
sudo pip3 install fastapi uvicorn sqlalchemy alembic

# Not ideal - Installing one by one
sudo pip3 install fastapi
sudo pip3 install uvicorn
# etc...
```

### 3. Use Stable Versions
For production projects, note specific versions:
```bash
# Development - latest is fine
sudo pip3 install django

# Production - specify version
sudo pip3 install django==4.2.7
```

### 4. Clean Regularly
Remove unused packages:
```bash
# Find unused Python packages
pip3 list --format=freeze | grep -v "^\-e" | cut -d = -f 1 | xargs -n1 pip3 show -f | grep -B1 "Required-by: $"
```

## Common Gotchas and Solutions

### Issue: Binary Dependencies
Some Python packages need system libraries:
```bash
# For pillow
sudo apt install libjpeg-dev zlib1g-dev

# For psycopg2
sudo apt install libpq-dev

# For mysqlclient
sudo apt install default-libmysqlclient-dev
```

### Issue: Permission Errors
Always use sudo for global installs:
```bash
# Wrong
pip3 install package

# Correct
sudo pip3 install package
```

### Issue: Path Problems
Ensure pip and npm binaries are in PATH:
```bash
# Add to ~/.bashrc
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Quick Reference Card

```bash
# Most Used Commands
sudo pip3 install [package]         # Install Python package
sudo npm install -g [package]       # Install Node package
sudo apt install [package]          # Install system package

pip3 list                          # List Python packages
npm list -g --depth=0              # List Node packages
dpkg -l | grep [pattern]           # List system packages

sudo pip3 install --upgrade [pkg]  # Update Python package
sudo npm update -g [package]        # Update Node package
sudo apt upgrade [package]          # Update system package

# Generate documentation
~/scripts/generate-dependency-guide.sh
```

## Next Steps

1. Install your core development stack
2. Create DEPENDENCY_GUIDE.md
3. Set up maintenance scripts
4. Continue to [Repository Organization](04-REPOSITORY_ORGANIZATION.md)

---

**Pro Tip**: The first time you set up a new project type, document the exact packages needed. This becomes your template for future projects!