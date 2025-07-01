# Integration Patterns Guide

This guide provides reusable patterns for common integrations. Build your own library of proven solutions that Claude can reference for future projects.

## Why Document Integration Patterns?

- **Instant reuse**: Claude can implement proven patterns immediately
- **Avoid mistakes**: Learn once, apply everywhere
- **Build faster**: Skip research and implementation phases
- **Consistency**: Use the same patterns across projects

## Structure for Pattern Documentation

Each integration pattern should follow this template:

```markdown
# [Integration Name] Pattern

## Overview
What this integration does and when to use it.

## Prerequisites
- Required packages
- API keys needed
- System requirements

## Environment Variables
\`\`\`bash
INTEGRATION_API_KEY=your_key_here
INTEGRATION_SECRET=your_secret_here
\`\`\`

## Implementation
[Step-by-step code with explanations]

## Common Issues
- Issue 1: Solution
- Issue 2: Solution

## Working Example
[Complete working code]

## Testing
How to verify the integration works
```

## Essential Integration Patterns

### 1. Stripe Payment Processing

Create `~/STRIPE_README.md`:

```markdown
# Stripe Integration Pattern

## Overview
Accept payments using Stripe Checkout with webhook handling.

## Prerequisites
```bash
# Python
sudo pip3 install stripe

# Node.js
sudo npm install -g stripe
```

## Environment Variables
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## Python Implementation

### Create Checkout Session
```python
import stripe
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()
stripe.api_key = os.getenv("STRIPE_SECRET_KEY")

@app.post("/create-checkout-session")
async def create_checkout(request: Request):
    data = await request.json()
    
    try:
        session = stripe.checkout.Session.create(
            payment_method_types=['card'],
            line_items=[{
                'price_data': {
                    'currency': 'usd',
                    'product_data': {
                        'name': data['product_name'],
                    },
                    'unit_amount': data['amount'],
                },
                'quantity': 1,
            }],
            mode='payment',
            success_url='https://yourdomain.com/success',
            cancel_url='https://yourdomain.com/cancel',
            metadata=data.get('metadata', {})
        )
        return JSONResponse({'url': session.url})
    except Exception as e:
        return JSONResponse({'error': str(e)}, status_code=400)
```

### Webhook Handler
```python
@app.post("/stripe-webhook")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')
    
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, os.getenv("STRIPE_WEBHOOK_SECRET")
        )
        
        if event['type'] == 'checkout.session.completed':
            session = event['data']['object']
            # Process successful payment
            handle_successful_payment(session)
            
        return JSONResponse({'received': True})
    except Exception as e:
        return JSONResponse({'error': str(e)}, status_code=400)
```

## Node.js Implementation

### Create Checkout Session
```javascript
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

app.post('/create-checkout-session', async (req, res) => {
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: {
            name: req.body.productName,
          },
          unit_amount: req.body.amount,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: 'https://yourdomain.com/success',
      cancel_url: 'https://yourdomain.com/cancel',
    });
    
    res.json({ url: session.url });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

## Testing
```bash
# Use Stripe CLI for webhook testing
stripe listen --forward-to localhost:3000/stripe-webhook
stripe trigger checkout.session.completed
```

## Common Issues
- **Webhook signature fails**: Check that webhook secret matches
- **CORS errors**: Add Stripe domains to allowed origins
- **Test mode**: Always use test keys during development
```

### 2. Email Service Integration

Create `~/EMAIL_SERVICE_README.md`:

```markdown
# Email Service Integration Pattern

## Overview
Send transactional emails using SMTP or email service APIs.

## Option 1: SMTP (Gmail Example)

### Prerequisites
```bash
# Python
sudo pip3 install python-dotenv email-validator fastapi-mail

# Node.js
sudo npm install -g nodemailer
```

### Environment Variables
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password  # Use app-specific password
```

### Python Implementation
```python
from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
from pydantic import EmailStr

conf = ConnectionConfig(
    MAIL_USERNAME = os.getenv("SMTP_USER"),
    MAIL_PASSWORD = os.getenv("SMTP_PASS"),
    MAIL_FROM = os.getenv("SMTP_USER"),
    MAIL_PORT = int(os.getenv("SMTP_PORT")),
    MAIL_SERVER = os.getenv("SMTP_HOST"),
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
)

async def send_email(email: EmailStr, subject: str, body: str):
    message = MessageSchema(
        subject=subject,
        recipients=[email],
        body=body,
        subtype="html"
    )
    
    fm = FastMail(conf)
    await fm.send_message(message)
```

### Node.js Implementation
```javascript
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

async function sendEmail(to, subject, html) {
  const info = await transporter.sendMail({
    from: process.env.SMTP_USER,
    to,
    subject,
    html,
  });
  
  return info.messageId;
}
```

## Option 2: SendGrid API

### Prerequisites
```bash
# Python
sudo pip3 install sendgrid

# Node.js
sudo npm install -g @sendgrid/mail
```

### Python Implementation
```python
import sendgrid
from sendgrid.helpers.mail import Mail

sg = sendgrid.SendGridAPIClient(api_key=os.getenv('SENDGRID_API_KEY'))

def send_email(to_email, subject, content):
    message = Mail(
        from_email='noreply@yourdomain.com',
        to_emails=to_email,
        subject=subject,
        html_content=content
    )
    
    try:
        response = sg.send(message)
        return response.status_code
    except Exception as e:
        print(f"Error: {e}")
        return None
```

## Email Templates
```python
def welcome_email_template(name, verification_link):
    return f"""
    <h1>Welcome {name}!</h1>
    <p>Thanks for signing up. Please verify your email:</p>
    <a href="{verification_link}" style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
        Verify Email
    </a>
    """
```

## Testing
- Use MailCatcher for local development
- Check spam folder for test emails
- Verify SPF/DKIM records for production
```

### 3. Database Connection Patterns

Create `~/DATABASE_PATTERNS_README.md`:

```markdown
# Database Connection Patterns

## PostgreSQL with Connection Pooling

### Prerequisites
```bash
# Python
sudo pip3 install psycopg2-binary sqlalchemy

# Node.js
sudo npm install -g pg
```

### Python Implementation
```python
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool
from contextlib import contextmanager

# Create engine with connection pooling
engine = create_engine(
    os.getenv("DATABASE_URL"),
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # Verify connections before using
)

@contextmanager
def get_db():
    connection = engine.connect()
    try:
        yield connection
    finally:
        connection.close()

# Usage
with get_db() as db:
    result = db.execute("SELECT * FROM users")
    users = result.fetchall()
```

### Node.js Implementation
```javascript
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Query function with automatic connection handling
async function query(text, params) {
  const start = Date.now();
  const res = await pool.query(text, params);
  const duration = Date.now() - start;
  console.log('Query executed', { text, duration, rows: res.rowCount });
  return res;
}

// Usage
const users = await query('SELECT * FROM users WHERE active = $1', [true]);
```

## MongoDB Connection

### Python Implementation
```python
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure

class MongoDBConnection:
    def __init__(self):
        self.client = None
        self.db = None
    
    def connect(self):
        try:
            self.client = MongoClient(os.getenv("MONGODB_URI"))
            self.client.admin.command('ping')
            self.db = self.client[os.getenv("DB_NAME")]
            print("MongoDB connected successfully")
        except ConnectionFailure:
            print("MongoDB connection failed")
    
    def get_collection(self, name):
        return self.db[name]

# Usage
mongo = MongoDBConnection()
mongo.connect()
users = mongo.get_collection("users")
```

## Redis Caching Pattern

```python
import redis
import json
from functools import wraps

redis_client = redis.from_url(os.getenv("REDIS_URL"))

def cache_result(expiration=3600):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Create cache key from function name and arguments
            cache_key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
            
            # Try to get from cache
            cached = redis_client.get(cache_key)
            if cached:
                return json.loads(cached)
            
            # Execute function and cache result
            result = func(*args, **kwargs)
            redis_client.setex(
                cache_key, 
                expiration, 
                json.dumps(result)
            )
            return result
        return wrapper
    return decorator

# Usage
@cache_result(expiration=3600)
def get_user_data(user_id):
    # Expensive database query
    return db.query(f"SELECT * FROM users WHERE id = {user_id}")
```
```

### 4. Authentication Patterns

Create `~/AUTH_PATTERNS_README.md`:

```markdown
# Authentication Patterns

## JWT Authentication

### Prerequisites
```bash
# Python
sudo pip3 install python-jose[cryptography] passlib[bcrypt] python-multipart

# Node.js
sudo npm install -g jsonwebtoken bcrypt
```

### Python Implementation (FastAPI)
```python
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

# Configuration
SECRET_KEY = os.getenv("JWT_SECRET_KEY")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Password hashing
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

# Token creation
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# Token verification
async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    # Get user from database
    user = get_user_by_username(username)
    if user is None:
        raise credentials_exception
    return user

# Protected route example
@app.get("/protected")
async def protected_route(current_user = Depends(get_current_user)):
    return {"message": f"Hello {current_user.username}"}
```

### Session-Based Auth
```python
from fastapi import Request, Response
import uuid

sessions = {}  # In production, use Redis

def create_session(user_id: str, response: Response):
    session_id = str(uuid.uuid4())
    sessions[session_id] = {
        "user_id": user_id,
        "created_at": datetime.utcnow()
    }
    response.set_cookie(
        key="session_id",
        value=session_id,
        httponly=True,
        secure=True,  # HTTPS only
        samesite="lax",
        max_age=86400  # 24 hours
    )
    return session_id

def get_session_user(request: Request):
    session_id = request.cookies.get("session_id")
    if not session_id or session_id not in sessions:
        return None
    return sessions[session_id]["user_id"]
```

## OAuth2 Integration (Google Example)

```python
from authlib.integrations.starlette_client import OAuth

oauth = OAuth()
oauth.register(
    name='google',
    client_id=os.getenv('GOOGLE_CLIENT_ID'),
    client_secret=os.getenv('GOOGLE_CLIENT_SECRET'),
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

@app.get('/login/google')
async def login_google(request: Request):
    redirect_uri = request.url_for('auth_google')
    return await oauth.google.authorize_redirect(request, redirect_uri)

@app.get('/auth/google')
async def auth_google(request: Request):
    token = await oauth.google.authorize_access_token(request)
    user_info = token.get('userinfo')
    # Create or update user in database
    return {"email": user_info['email']}
```
```

### 5. API Client Patterns

Create `~/API_CLIENT_README.md`:

```markdown
# API Client Patterns

## RESTful API Client (Python)

### Using httpx (Async)
```python
import httpx
from typing import Dict, Any, Optional
import asyncio
from tenacity import retry, stop_after_attempt, wait_exponential

class APIClient:
    def __init__(self, base_url: str, api_key: str):
        self.base_url = base_url.rstrip('/')
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        self.client = httpx.AsyncClient(headers=self.headers, timeout=30.0)
    
    @retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
    async def request(self, method: str, endpoint: str, **kwargs) -> Dict[str, Any]:
        url = f"{self.base_url}/{endpoint.lstrip('/')}"
        
        try:
            response = await self.client.request(method, url, **kwargs)
            response.raise_for_status()
            return response.json()
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 429:  # Rate limit
                retry_after = int(e.response.headers.get('Retry-After', '60'))
                await asyncio.sleep(retry_after)
                raise
            raise
    
    async def get(self, endpoint: str, params: Optional[Dict] = None):
        return await self.request("GET", endpoint, params=params)
    
    async def post(self, endpoint: str, data: Dict):
        return await self.request("POST", endpoint, json=data)
    
    async def close(self):
        await self.client.aclose()

# Usage
async def main():
    client = APIClient("https://api.example.com", "your-api-key")
    try:
        users = await client.get("/users", params={"limit": 10})
        new_user = await client.post("/users", data={"name": "John Doe"})
    finally:
        await client.close()
```

### GraphQL Client
```python
import httpx
from typing import Dict, Any

class GraphQLClient:
    def __init__(self, url: str, headers: Dict[str, str] = None):
        self.url = url
        self.headers = headers or {}
    
    async def execute(self, query: str, variables: Dict[str, Any] = None):
        async with httpx.AsyncClient() as client:
            response = await client.post(
                self.url,
                json={"query": query, "variables": variables or {}},
                headers=self.headers
            )
            response.raise_for_status()
            data = response.json()
            
            if "errors" in data:
                raise Exception(f"GraphQL errors: {data['errors']}")
            
            return data["data"]

# Usage
client = GraphQLClient(
    "https://api.example.com/graphql",
    headers={"Authorization": "Bearer token"}
)

query = """
    query GetUser($id: ID!) {
        user(id: $id) {
            id
            name
            email
        }
    }
"""

user = await client.execute(query, {"id": "123"})
```

## Node.js API Client

### Using Axios with Interceptors
```javascript
const axios = require('axios');

class APIClient {
  constructor(baseURL, apiKey) {
    this.client = axios.create({
      baseURL,
      headers: {
        'Authorization': `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      timeout: 30000,
    });
    
    this.setupInterceptors();
  }
  
  setupInterceptors() {
    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        console.log(`${config.method.toUpperCase()} ${config.url}`);
        return config;
      },
      (error) => Promise.reject(error)
    );
    
    // Response interceptor with retry logic
    this.client.interceptors.response.use(
      (response) => response.data,
      async (error) => {
        const originalRequest = error.config;
        
        if (error.response?.status === 429 && !originalRequest._retry) {
          originalRequest._retry = true;
          const retryAfter = error.response.headers['retry-after'] || 60;
          
          await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
          return this.client(originalRequest);
        }
        
        return Promise.reject(error);
      }
    );
  }
  
  async get(endpoint, params = {}) {
    return this.client.get(endpoint, { params });
  }
  
  async post(endpoint, data) {
    return this.client.post(endpoint, data);
  }
  
  async put(endpoint, data) {
    return this.client.put(endpoint, data);
  }
  
  async delete(endpoint) {
    return this.client.delete(endpoint);
  }
}

// Usage
const client = new APIClient('https://api.example.com', 'your-api-key');

// With error handling
try {
  const users = await client.get('/users', { limit: 10 });
  const newUser = await client.post('/users', { name: 'John Doe' });
} catch (error) {
  if (error.response) {
    console.error('API Error:', error.response.data);
  } else {
    console.error('Network Error:', error.message);
  }
}
```
```

### 6. File Upload Patterns

Create `~/FILE_UPLOAD_README.md`:

```markdown
# File Upload Patterns

## Python File Uploads

### FastAPI with Progress Tracking
```python
from fastapi import FastAPI, UploadFile, File, BackgroundTasks
from fastapi.responses import JSONResponse
import aiofiles
import hashlib
from pathlib import Path
import magic

app = FastAPI()

ALLOWED_MIME_TYPES = {
    'image/jpeg', 'image/png', 'image/gif',
    'application/pdf', 'text/plain'
}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

@app.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    # Validate file size
    contents = await file.read()
    if len(contents) > MAX_FILE_SIZE:
        return JSONResponse(
            status_code=413,
            content={"error": "File too large"}
        )
    
    # Validate MIME type
    mime = magic.from_buffer(contents, mime=True)
    if mime not in ALLOWED_MIME_TYPES:
        return JSONResponse(
            status_code=415,
            content={"error": f"File type {mime} not allowed"}
        )
    
    # Generate unique filename
    hash_md5 = hashlib.md5(contents).hexdigest()
    ext = Path(file.filename).suffix
    new_filename = f"{hash_md5}{ext}"
    
    # Save file
    upload_dir = Path("uploads")
    upload_dir.mkdir(exist_ok=True)
    file_path = upload_dir / new_filename
    
    async with aiofiles.open(file_path, 'wb') as f:
        await f.write(contents)
    
    # Schedule background processing
    background_tasks.add_task(process_uploaded_file, file_path)
    
    return {
        "filename": new_filename,
        "size": len(contents),
        "mime_type": mime,
        "url": f"/files/{new_filename}"
    }

async def process_uploaded_file(file_path: Path):
    # Add your processing logic here
    # e.g., generate thumbnails, extract text, etc.
    pass

# Chunked upload for large files
@app.post("/upload/chunked/{upload_id}")
async def upload_chunk(
    upload_id: str,
    chunk_number: int,
    chunk: UploadFile = File(...)
):
    chunk_dir = Path(f"chunks/{upload_id}")
    chunk_dir.mkdir(parents=True, exist_ok=True)
    
    chunk_path = chunk_dir / f"chunk_{chunk_number:06d}"
    async with aiofiles.open(chunk_path, 'wb') as f:
        contents = await chunk.read()
        await f.write(contents)
    
    return {"chunk": chunk_number, "size": len(contents)}

@app.post("/upload/complete/{upload_id}")
async def complete_upload(upload_id: str, filename: str):
    chunk_dir = Path(f"chunks/{upload_id}")
    output_path = Path(f"uploads/{filename}")
    
    # Combine chunks
    async with aiofiles.open(output_path, 'wb') as output:
        for chunk_file in sorted(chunk_dir.glob("chunk_*")):
            async with aiofiles.open(chunk_file, 'rb') as chunk:
                await output.write(await chunk.read())
            chunk_file.unlink()  # Delete chunk after writing
    
    chunk_dir.rmdir()  # Remove chunk directory
    return {"filename": filename, "path": str(output_path)}
```

### Direct to S3 Upload
```python
import boto3
from botocore.exceptions import ClientError
from datetime import datetime, timedelta

def generate_presigned_post(bucket: str, key: str, expiration=3600):
    """Generate a presigned POST URL for S3 upload"""
    s3_client = boto3.client('s3')
    
    try:
        response = s3_client.generate_presigned_post(
            Bucket=bucket,
            Key=key,
            Fields={
                "Content-Type": "image/jpeg",
                "x-amz-server-side-encryption": "AES256"
            },
            Conditions=[
                {"Content-Type": "image/jpeg"},
                ["content-length-range", 0, 10485760],  # Max 10MB
                {"x-amz-server-side-encryption": "AES256"}
            ],
            ExpiresIn=expiration
        )
        return response
    except ClientError as e:
        print(f"Error generating presigned URL: {e}")
        return None

# Usage in FastAPI
@app.post("/get-upload-url")
async def get_upload_url(filename: str):
    key = f"uploads/{datetime.now().strftime('%Y/%m/%d')}/{filename}"
    presigned_post = generate_presigned_post("my-bucket", key)
    
    if presigned_post:
        return presigned_post
    else:
        return JSONResponse(
            status_code=500,
            content={"error": "Could not generate upload URL"}
        )
```

## Node.js File Uploads

### Express with Multer
```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const crypto = require('crypto');
const sharp = require('sharp');

const app = express();

// Configure storage
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = path.join(__dirname, 'uploads', new Date().toISOString().split('T')[0]);
    await fs.promises.mkdir(uploadPath, { recursive: true });
    cb(null, uploadPath);
  },
  filename: (req, file, cb) => {
    const hash = crypto.randomBytes(16).toString('hex');
    const ext = path.extname(file.originalname);
    cb(null, `${hash}${ext}`);
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|pdf/;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);
  
  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Invalid file type'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB
  }
});

// Single file upload
app.post('/upload', upload.single('file'), async (req, res) => {
  try {
    const file = req.file;
    
    // Process image if needed
    if (file.mimetype.startsWith('image/')) {
      const thumbnailPath = file.path.replace(/\.([^.]+)$/, '-thumb.$1');
      
      await sharp(file.path)
        .resize(200, 200, { fit: 'cover' })
        .toFile(thumbnailPath);
      
      file.thumbnail = thumbnailPath;
    }
    
    res.json({
      filename: file.filename,
      originalName: file.originalname,
      size: file.size,
      path: file.path,
      thumbnail: file.thumbnail
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Multiple file upload
app.post('/upload-multiple', upload.array('files', 5), (req, res) => {
  const files = req.files.map(file => ({
    filename: file.filename,
    originalName: file.originalname,
    size: file.size
  }));
  
  res.json({ files });
});

// Streaming upload for large files
app.post('/upload-stream', (req, res) => {
  const busboy = new Busboy({ headers: req.headers });
  
  busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
    const saveTo = path.join(__dirname, 'uploads', `${Date.now()}-${filename}`);
    const writeStream = fs.createWriteStream(saveTo);
    
    let uploadedBytes = 0;
    
    file.on('data', (data) => {
      uploadedBytes += data.length;
      // Report progress
      const progress = (uploadedBytes / req.headers['content-length']) * 100;
      console.log(`Upload progress: ${progress.toFixed(2)}%`);
    });
    
    file.pipe(writeStream);
    
    writeStream.on('finish', () => {
      res.json({
        filename,
        size: uploadedBytes,
        path: saveTo
      });
    });
  });
  
  req.pipe(busboy);
});
```
```

## Creating Your Pattern Library

### Directory Structure
```
~/patterns/
├── payments/
│   ├── stripe.md
│   ├── paypal.md
│   └── crypto.md
├── auth/
│   ├── jwt.md
│   ├── oauth.md
│   └── sessions.md
├── email/
│   ├── smtp.md
│   ├── sendgrid.md
│   └── templates.md
├── database/
│   ├── postgres.md
│   ├── mongodb.md
│   └── redis.md
├── api/
│   ├── rest-client.md
│   ├── graphql.md
│   └── websocket.md
├── files/
│   ├── uploads.md
│   ├── s3.md
│   └── image-processing.md
└── README.md
```

### Pattern Template
```markdown
# [Pattern Name]

## Last Updated
YYYY-MM-DD

## Projects Using This
- project-1
- project-2

## Quick Start
```bash
# Installation
sudo pip3 install required-package

# Environment variables
export API_KEY=your_key_here
```

## Implementation
[Complete working code]

## Gotchas
- Common mistake 1
- Common mistake 2

## Resources
- [Official Documentation](link)
- [Tutorial](link)
```

## Maintaining Your Pattern Library

### After Each Project
1. Document new integrations
2. Update existing patterns with improvements
3. Note any issues encountered
4. Add to the "Projects Using This" list

### Regular Reviews
- Monthly: Update package versions
- Quarterly: Test all patterns still work
- Yearly: Archive obsolete patterns

## Next Steps

1. Create your patterns directory
2. Document your first integration
3. Build your library over time
4. Continue to [Best Practices](06-BEST_PRACTICES.md)

---

**Pro Tip**: The best pattern library is one that's actually used. Keep entries concise, practical, and tested!