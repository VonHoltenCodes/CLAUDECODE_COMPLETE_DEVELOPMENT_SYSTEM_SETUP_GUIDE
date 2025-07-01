# Repository Organization Guide

A well-organized repository structure is crucial for efficient development with Claude Code. This guide shows you how to organize projects for maximum productivity.

## Directory Structure

### Base Structure
```
~/repos/
├── projects/         # Active development projects
├── learning/         # Tutorials, courses, experiments
├── archived/         # Completed or inactive projects
├── forks/           # Forked repositories
└── REPOSITORY_INDEX.md  # Master catalog
```

### Why This Structure?
- **Clear categorization**: Claude knows where to find things
- **Easy navigation**: Simple commands to jump between projects
- **Status tracking**: Active vs archived is immediately clear
- **Fork management**: Keeps contributions separate from original work

## Setting Up the Structure

### Initial Creation
```bash
#!/bin/bash
# setup-repos.sh

# Create directory structure
mkdir -p ~/repos/{projects,learning,archived,forks}

# Create repository index
cat > ~/repos/REPOSITORY_INDEX.md << 'EOF'
# Repository Index

Last Updated: $(date)

## Directory Structure
\`\`\`
~/repos/
├── projects/         # Active development
├── learning/         # Tutorials and experiments  
├── archived/         # Completed projects
└── forks/           # Forked repositories
\`\`\`

## Active Projects

### projects/
<!-- Add projects here -->

### learning/
<!-- Add learning projects here -->

### archived/
<!-- Add archived projects here -->

### forks/
<!-- Add forks here -->

## Quick Commands
\`\`\`bash
# Go to projects
cd ~/repos/projects

# List all projects
ls -la ~/repos/projects/

# Check git status of all projects
for repo in ~/repos/projects/*; do
    echo "=== $(basename $repo) ==="
    git -C "$repo" status -s
done
\`\`\`
EOF

echo "Repository structure created!"
```

### Adding Helpful Aliases
```bash
# Add to ~/.bashrc
cat >> ~/.bashrc << 'EOF'

# Repository shortcuts
alias repos='cd ~/repos'
alias projects='cd ~/repos/projects'
alias learning='cd ~/repos/learning'

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
new-project() {
    if [ -z "$1" ]; then
        echo "Usage: new-project <project-name>"
        return 1
    fi
    
    mkdir -p ~/repos/projects/$1
    cd ~/repos/projects/$1
    git init
    
    # Create standard structure
    mkdir -p src tests docs
    
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
EOF

source ~/.bashrc
```

## Project Organization Best Practices

### 1. Consistent Naming
```
# Good naming
my-awesome-api
user-dashboard
data-analysis-tool

# Avoid
MyProject
test1
proj
```

### 2. Standard Project Structure

#### For Python Projects
```
project-name/
├── README.md
├── requirements.txt
├── .gitignore
├── .env.example
├── src/
│   ├── __init__.py
│   └── main.py
├── tests/
│   └── test_main.py
├── docs/
│   └── API.md
└── scripts/
    └── setup.sh
```

#### For Node.js Projects
```
project-name/
├── README.md
├── package.json
├── .gitignore
├── .env.example
├── src/
│   └── index.js
├── tests/
│   └── index.test.js
├── public/
│   └── index.html
└── docs/
    └── API.md
```

### 3. Documentation Standards

Every project should have:
- **README.md**: Overview, setup, usage
- **.env.example**: Required environment variables
- **docs/**: Detailed documentation
- **CHANGELOG.md**: Version history (for released projects)

## Repository Index Management

### Automated Index Updates

Create a script to automatically update REPOSITORY_INDEX.md:

```bash
#!/bin/bash
# update-repo-index.sh

cat > ~/repos/REPOSITORY_INDEX.md << 'EOF'
# Repository Index

Last Updated: $(date)

## Directory Structure
\`\`\`
~/repos/
├── projects/         # Active development
├── learning/         # Tutorials and experiments  
├── archived/         # Completed projects
└── forks/           # Forked repositories
\`\`\`

## Active Projects ($(ls -1 ~/repos/projects | wc -l) total)

EOF

# List projects with git info
for dir in ~/repos/projects/*/; do
    if [ -d "$dir/.git" ]; then
        cd "$dir"
        project_name=$(basename "$dir")
        last_commit=$(git log -1 --format="%cr" 2>/dev/null || echo "No commits")
        branch=$(git branch --show-current 2>/dev/null || echo "No branch")
        
        # Check for language
        if [ -f "package.json" ]; then
            lang="Node.js"
        elif [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
            lang="Python"
        else
            lang="Unknown"
        fi
        
        echo "### $project_name" >> ~/repos/REPOSITORY_INDEX.md
        echo "- **Language**: $lang" >> ~/repos/REPOSITORY_INDEX.md
        echo "- **Branch**: $branch" >> ~/repos/REPOSITORY_INDEX.md
        echo "- **Last Commit**: $last_commit" >> ~/repos/REPOSITORY_INDEX.md
        echo "" >> ~/repos/REPOSITORY_INDEX.md
    fi
done

echo "Repository index updated!"
```

### Make it a Git Repository

Track your repos structure itself:
```bash
cd ~/repos
git init
git add REPOSITORY_INDEX.md
git commit -m "Initial repository index"
```

## GitHub Integration

### Clone All Your Repositories

If you have many repositories on GitHub:

```bash
#!/bin/bash
# clone-all-repos.sh

# Requires GitHub CLI (gh) to be installed and authenticated

echo "Cloning all repositories..."

# Clone personal repos to projects
gh repo list --limit 1000 --json name,isPrivate,isFork | \
jq -r '.[] | select(.isFork == false) | .name' | \
while read repo; do
    if [ ! -d "~/repos/projects/$repo" ]; then
        echo "Cloning $repo..."
        git clone "git@github.com:$(gh api user --jq .login)/$repo.git" \
            "~/repos/projects/$repo"
    fi
done

# Clone forks to forks directory
gh repo list --limit 1000 --json name,isPrivate,isFork | \
jq -r '.[] | select(.isFork == true) | .name' | \
while read repo; do
    if [ ! -d "~/repos/forks/$repo" ]; then
        echo "Cloning fork: $repo..."
        git clone "git@github.com:$(gh api user --jq .login)/$repo.git" \
            "~/repos/forks/$repo"
    fi
done

echo "All repositories cloned!"
```

### Keep Repositories Updated

```bash
#!/bin/bash
# update-all-repos.sh

echo "Updating all repositories..."

for repo in ~/repos/projects/*/; do
    if [ -d "$repo/.git" ]; then
        echo -e "\nUpdating $(basename "$repo")..."
        git -C "$repo" fetch --all
        
        # Only pull if on a branch
        if git -C "$repo" symbolic-ref HEAD &>/dev/null; then
            git -C "$repo" pull
        fi
    fi
done

echo "All repositories updated!"
```

## Project Lifecycle Management

### Moving to Archive

When a project is complete:
```bash
# Archive a project
archive-project() {
    if [ -z "$1" ]; then
        echo "Usage: archive-project <project-name>"
        return 1
    fi
    
    if [ -d "~/repos/projects/$1" ]; then
        mv ~/repos/projects/$1 ~/repos/archived/
        echo "Project $1 archived"
        # Update repository index
        ~/scripts/update-repo-index.sh
    else
        echo "Project $1 not found"
    fi
}
```

### Reviving from Archive

```bash
# Revive an archived project
revive-project() {
    if [ -z "$1" ]; then
        echo "Usage: revive-project <project-name>"
        return 1
    fi
    
    if [ -d "~/repos/archived/$1" ]; then
        mv ~/repos/archived/$1 ~/repos/projects/
        echo "Project $1 revived"
        # Update repository index
        ~/scripts/update-repo-index.sh
    else
        echo "Archived project $1 not found"
    fi
}
```

## Integration with Claude

### Project Context Files

In each project, create a `CLAUDE.md` file:

```markdown
# Claude Context for [Project Name]

## Project Overview
Brief description of what this project does.

## Current Status
- [ ] Planning
- [x] In Development
- [ ] Testing
- [ ] Deployed

## Tech Stack
- Language: Python 3.11
- Framework: FastAPI
- Database: PostgreSQL
- Cache: Redis

## Key Files
- `src/main.py` - Application entry point
- `src/api/routes.py` - API endpoints
- `src/models/user.py` - User model

## Current Tasks
1. Implement user authentication
2. Add email notifications
3. Set up CI/CD

## Known Issues
- None currently

## Deployment
- Local: `uvicorn src.main:app --reload`
- Production: Deployed on AWS EC2
```

### Quick Project Summary

Create a command to show all project contexts:

```bash
# Show all Claude context files
claude-context() {
    for claude_file in ~/repos/projects/*/CLAUDE.md; do
        if [ -f "$claude_file" ]; then
            echo -e "\n=== $(basename $(dirname "$claude_file")) ==="
            head -n 20 "$claude_file"
        fi
    done
}
```

## Maintenance Routine

### Daily
- Update CLAUDE.md in active projects
- Commit work in progress

### Weekly
- Run `update-repo-index.sh`
- Archive completed projects
- Clean up test/temporary projects

### Monthly
- Review archived projects
- Update all repositories from remotes
- Clean up old branches

## Next Steps

1. Set up your repository structure
2. Create helpful aliases and scripts
3. Initialize repository tracking
4. Continue to [Integration Patterns](05-INTEGRATION_PATTERNS.md)

---

**Remember**: A well-organized repository structure saves hours of searching and confusion. Invest time in organization now for massive productivity gains later!