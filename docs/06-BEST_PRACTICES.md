# Best Practices Guide

This guide consolidates the key learnings and best practices for maximizing productivity with Claude Code.

## Core Principles

### 1. Documentation First
- **Always document before you delete**: Capture patterns, solutions, and configurations
- **Update documentation immediately**: Don't wait until "later"
- **Be specific**: Include versions, exact commands, and error messages
- **Document failures**: They're as valuable as successes

### 2. Global Development Philosophy
- **Embrace simplicity**: Global installations reduce complexity
- **Ship fast**: Working code today beats perfect code tomorrow
- **Iterate quickly**: Get feedback early and often
- **Trust Claude**: Let it handle system management tasks

### 3. Project Organization
- **Clear structure**: Projects, learning, archived, forks
- **Consistent naming**: Use kebab-case for all projects
- **Regular cleanup**: Archive completed projects monthly
- **Index everything**: Maintain REPOSITORY_INDEX.md religiously

## Development Workflow

### Starting a New Project

1. **Create Project Structure**
```bash
# Use the mkproject function
mkproject my-awesome-api

# Or manually
mkdir -p ~/repos/projects/my-awesome-api
cd ~/repos/projects/my-awesome-api
git init
```

2. **Create CLAUDE.md Immediately**
```markdown
# Claude Context for My Awesome API

## Project Overview
Building an API for [purpose]

## Tech Stack
- Language: Python/Node.js
- Framework: FastAPI/Express
- Database: PostgreSQL/MongoDB

## Current Status
- [ ] Planning
- [x] In Development
- [ ] Testing
- [ ] Deployed

## Key Files
- `src/main.py` - Entry point
- `README.md` - User documentation

## Current Tasks
1. Set up basic structure
2. Implement core features
3. Add tests

## Known Issues
- None yet

## Commands
- Run: `uvicorn src.main:app --reload`
- Test: `pytest tests/`
- Lint: `black . && flake8`
```

3. **Set Up Git Early**
```bash
git add .
git commit -m "Initial project structure"
git remote add origin git@github.com:username/my-awesome-api.git
git push -u origin main
```

### During Development

#### Commit Often
```bash
# Stage and commit frequently
git add -A
git commit -m "Add user authentication endpoint"

# Push at natural breakpoints
git push
```

#### Document as You Go
- Update CLAUDE.md with new files and changes
- Add learned patterns to your pattern library
- Note any issues or workarounds

#### Use Claude's Strengths
- Let Claude handle repetitive tasks
- Ask for entire file implementations
- Use Claude for debugging and optimization

### Project Completion

1. **Final Documentation**
   - Update README.md with complete usage instructions
   - Document all environment variables
   - Include deployment instructions

2. **Clean Up**
   - Remove debug code
   - Delete unused dependencies
   - Run final tests

3. **Archive or Deploy**
```bash
# If archiving
archive-project my-awesome-api

# If deploying
# Document deployment process in SERVER_DEPLOYMENT_README.md
```

## Common Patterns and Solutions

### Environment Variable Management

**Development (.env)**
```bash
# Development environment
DEBUG=true
DATABASE_URL=postgresql://localhost/myapp_dev
REDIS_URL=redis://localhost:6379
API_KEY=dev_key_here
```

**Production (.env.production)**
```bash
# Production environment
DEBUG=false
DATABASE_URL=postgresql://prod-server/myapp
REDIS_URL=redis://prod-redis:6379
API_KEY=prod_key_here
```

**Loading Strategy**
```python
# Python
from dotenv import load_dotenv
import os

# Load environment-specific file
env = os.getenv('ENVIRONMENT', 'development')
load_dotenv(f'.env.{env}')

# Node.js
require('dotenv').config({ 
  path: `.env.${process.env.NODE_ENV || 'development'}` 
})
```

### Error Handling Patterns

#### Python Global Error Handler
```python
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
import logging

app = FastAPI()
logger = logging.getLogger(__name__)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    
    # Don't expose internal errors in production
    if os.getenv("DEBUG") == "true":
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": str(exc), "type": type(exc).__name__}
        )
    else:
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"detail": "Internal server error"}
        )
```

#### Node.js Global Error Handler
```javascript
// Express error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  
  const isDevelopment = process.env.NODE_ENV === 'development';
  
  res.status(err.status || 500).json({
    message: err.message,
    ...(isDevelopment && { stack: err.stack })
  });
});

// Unhandled promise rejections
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  // Application specific logging, throwing an error, or other logic here
});
```

### Testing Strategies

#### Quick Test Setup
```python
# Python - pytest
# conftest.py
import pytest
from fastapi.testclient import TestClient
from app.main import app

@pytest.fixture
def client():
    return TestClient(app)

@pytest.fixture
def auth_headers():
    return {"Authorization": "Bearer test-token"}

# test_users.py
def test_create_user(client):
    response = client.post("/users", json={"email": "test@example.com"})
    assert response.status_code == 201
```

```javascript
// Node.js - Jest
// setup.js
beforeAll(async () => {
  // Setup test database
});

afterAll(async () => {
  // Cleanup
});

// users.test.js
const request = require('supertest');
const app = require('../src/app');

describe('Users API', () => {
  test('POST /users creates a new user', async () => {
    const res = await request(app)
      .post('/users')
      .send({ email: 'test@example.com' });
    
    expect(res.statusCode).toBe(201);
    expect(res.body).toHaveProperty('id');
  });
});
```

### Performance Optimization

#### Database Query Optimization
```python
# Bad - N+1 queries
users = User.query.all()
for user in users:
    print(user.posts)  # Each iteration queries database

# Good - Eager loading
users = User.query.options(joinedload(User.posts)).all()
for user in users:
    print(user.posts)  # No additional queries
```

#### Caching Strategy
```python
from functools import lru_cache
import redis

redis_client = redis.Redis()

def cached(expiration=3600):
    def decorator(func):
        def wrapper(*args, **kwargs):
            cache_key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
            cached_value = redis_client.get(cache_key)
            
            if cached_value:
                return json.loads(cached_value)
            
            result = func(*args, **kwargs)
            redis_client.setex(cache_key, expiration, json.dumps(result))
            return result
        return wrapper
    return decorator

@cached(expiration=7200)
def expensive_calculation(user_id):
    # Expensive operation
    return result
```

## Security Best Practices

### Never Commit Secrets
```bash
# .gitignore must include
.env
.env.*
*.pem
*.key
secrets/
```

### Input Validation
```python
from pydantic import BaseModel, EmailStr, validator

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    age: int
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v
    
    @validator('age')
    def age_validation(cls, v):
        if v < 18:
            raise ValueError('Must be 18 or older')
        return v
```

### Rate Limiting
```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

@app.post("/api/login")
@limiter.limit("5/minute")
async def login(request: Request, credentials: LoginCredentials):
    # Login logic
    pass
```

## Debugging Techniques

### Effective Logging
```python
import logging
from datetime import datetime

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Log with context
def process_order(order_id, user_id):
    logger.info(f"Processing order", extra={
        "order_id": order_id,
        "user_id": user_id,
        "timestamp": datetime.utcnow().isoformat()
    })
    
    try:
        # Process order
        pass
    except Exception as e:
        logger.error(f"Order processing failed", extra={
            "order_id": order_id,
            "user_id": user_id,
            "error": str(e),
            "error_type": type(e).__name__
        }, exc_info=True)
        raise
```

### Quick Debugging Tools
```python
# Python - Rich for beautiful debugging
from rich import print
from rich.console import Console
from rich.traceback import install

install()  # Beautiful tracebacks
console = Console()

# Debug print with syntax highlighting
console.print({"user": user_data}, style="bold green")

# Inspect objects
console.print(inspect(my_object))
```

```javascript
// Node.js - Debug module
const debug = require('debug')('app:users');

debug('Processing user %d', userId);

// Enable with: DEBUG=app:* node app.js
```

## Deployment Checklist

### Pre-Deployment
- [ ] All tests passing
- [ ] Environment variables documented
- [ ] Database migrations ready
- [ ] Static files optimized
- [ ] Security headers configured
- [ ] Error logging set up
- [ ] Monitoring configured

### Deployment Commands
```bash
# Python/FastAPI
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker

# Node.js/Express
pm2 start app.js -i max --name my-app
pm2 save
pm2 startup
```

### Post-Deployment
- [ ] Verify all endpoints working
- [ ] Check error logs
- [ ] Monitor performance
- [ ] Set up backups
- [ ] Document deployment process

## Working with Claude Code

### Effective Prompting
1. **Be specific about requirements**
   - Include exact package names
   - Specify versions if important
   - Mention any constraints

2. **Provide context**
   - Share relevant code snippets
   - Explain the bigger picture
   - Include error messages

3. **Request complete solutions**
   - Ask for full file implementations
   - Request test cases
   - Include error handling

### Claude's Strengths
- **Code generation**: Let Claude write boilerplate
- **Debugging**: Paste errors for quick solutions
- **Refactoring**: Ask for optimizations
- **Documentation**: Generate comprehensive docs
- **Testing**: Request test suites

### Common Claude Commands
```bash
# Let Claude see your project structure
ls -la
cat CLAUDE.md

# Show Claude your dependencies
cat requirements.txt  # or package.json

# Let Claude understand your code
cat src/main.py

# Ask Claude to run and debug
python src/main.py
# [Share any errors with Claude]
```

## Maintenance Routines

### Daily
- Commit work in progress
- Update CLAUDE.md for active projects
- Review and clear any debug logs

### Weekly
- Update REPOSITORY_INDEX.md
- Run update-all-repos.sh
- Clean up unused branches
- Update dependencies for active projects

### Monthly
- Archive completed projects
- Update system documentation
- Review and update pattern library
- Clean up old Docker images and containers
- Backup important databases

### Quarterly
- Full system update
- Review and prune installed packages
- Audit security of all active projects
- Update all documentation

## Final Tips

1. **Trust the Process**: This system is designed for speed and efficiency
2. **Document Everything**: Your future self will thank you
3. **Use Claude Liberally**: It's here to help, not judge
4. **Keep It Simple**: Complexity is the enemy of productivity
5. **Ship Often**: Real feedback beats theoretical perfection

## Conclusion

This development system prioritizes:
- **Speed over perfection**
- **Simplicity over complexity**
- **Action over planning**
- **Results over process**

Remember: The goal is to build things quickly and efficiently. Use these practices as guidelines, not rigid rules. Adapt them to your needs and keep building!

---

**Happy Coding with Claude! 🚀**