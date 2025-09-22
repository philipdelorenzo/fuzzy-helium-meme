# fuzzy-helium-meme

A simple PostgreSQL client library designed specifically for connecting to AWS Aurora clusters. This library provides an easy-to-use interface for database operations with built-in connection pooling, IAM authentication support, and Aurora-specific optimizations.

## Features

- 🚀 Simple and intuitive API
- 🔄 Built-in connection pooling
- 🔐 IAM authentication support for Aurora
- 🛡️ SSL/TLS encryption by default
- 🎯 Aurora-specific optimizations
- 📊 Comprehensive error handling
- 🧪 Full test coverage
- 📖 Type hints throughout

## Installation

```bash
pip install fuzzy-helium-meme
```

Or install from source:

```bash
git clone https://github.com/philipdelorenzo/fuzzy-helium-meme.git
cd fuzzy-helium-meme
pip install -e .
```

## Quick Start

### Basic Usage

```python
from aurora_client import AuroraClient, AuroraConfig

# Create configuration
config = AuroraConfig(
    host="your-cluster.cluster-xyz.us-east-1.rds.amazonaws.com",
    username="your_username",
    password="your_password",
    database="your_database"
)

# Use the client
with AuroraClient(config) as client:
    # Test connection
    if client.test_connection():
        print("Connected successfully!")
        
        # Execute queries
        users = client.execute_query("SELECT * FROM users WHERE active = %(active)s", {"active": True})
        for user in users:
            print(f"User: {user['name']} ({user['email']})")
```

### Configuration from Environment Variables

```python
import os
from aurora_client import AuroraClient, AuroraConfig

# Set environment variables
os.environ["AURORA_HOST"] = "your-cluster.cluster-xyz.us-east-1.rds.amazonaws.com"
os.environ["AURORA_USERNAME"] = "your_username"
os.environ["AURORA_PASSWORD"] = "your_password"
os.environ["AURORA_DATABASE"] = "your_database"

# Load configuration from environment
config = AuroraConfig.from_env()

with AuroraClient(config) as client:
    result = client.execute_query("SELECT NOW() as current_time")
    print(f"Current time: {result[0]['current_time']}")
```

### IAM Authentication

```python
from aurora_client import AuroraClient, AuroraConfig

config = AuroraConfig(
    host="your-cluster.cluster-xyz.us-east-1.rds.amazonaws.com",
    username="your_db_username",
    use_iam=True,
    region="us-east-1"
)

with AuroraClient(config) as client:
    users = client.execute_query("SELECT * FROM users")
```

## Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `host` | str | Required | Aurora cluster endpoint |
| `port` | int | 5432 | Database port |
| `database` | str | "postgres" | Database name |
| `username` | str | None | Database username |
| `password` | str | None | Database password (not needed with IAM) |
| `ssl_mode` | str | "require" | SSL mode (require, prefer, disable) |
| `connect_timeout` | int | 30 | Connection timeout in seconds |
| `region` | str | "us-east-1" | AWS region for IAM auth |
| `use_iam` | bool | False | Use IAM database authentication |

## Environment Variables

The client can be configured using environment variables:

- `AURORA_HOST` - Aurora cluster endpoint (required)
- `AURORA_PORT` - Database port (default: 5432)
- `AURORA_DATABASE` - Database name (default: postgres)
- `AURORA_USERNAME` - Database username
- `AURORA_PASSWORD` - Database password
- `AURORA_SSL_MODE` - SSL mode (default: require)
- `AURORA_CONNECT_TIMEOUT` - Connection timeout (default: 30)
- `AWS_REGION` - AWS region (default: us-east-1)
- `AURORA_USE_IAM` - Use IAM authentication (default: false)

## Advanced Usage

### Transaction Management

```python
with AuroraClient(config) as client:
    # Manual transaction management
    with client.begin_transaction() as tx:
        tx.execute("INSERT INTO users (name) VALUES (%(name)s)", {"name": "John"})
        tx.execute("INSERT INTO profiles (user_id) VALUES (%(user_id)s)", {"user_id": 1})
        # Automatically commits on success, rolls back on exception
```

### Batch Operations

```python
with AuroraClient(config) as client:
    # Insert multiple records efficiently
    users_data = [
        ("Alice", "alice@example.com"),
        ("Bob", "bob@example.com"),
        ("Charlie", "charlie@example.com")
    ]
    
    client.execute_many(
        "INSERT INTO users (name, email) VALUES (%s, %s)",
        users_data
    )
```

### Connection Pooling

```python
# Configure connection pool size
client = AuroraClient(config, pool_size=5, max_connections=20)

# The client automatically manages connections from the pool
with client:
    # Each query gets a connection from the pool
    result1 = client.execute_query("SELECT * FROM table1")
    result2 = client.execute_query("SELECT * FROM table2")
```

## Error Handling

The library provides specific exceptions for different error scenarios:

```python
from aurora_client import AuroraClient, AuroraConfig
from aurora_client.exceptions import ConnectionError, QueryError, ConfigurationError

try:
    config = AuroraConfig.from_env()
    with AuroraClient(config) as client:
        result = client.execute_query("SELECT * FROM non_existent_table")
        
except ConfigurationError as e:
    print(f"Configuration error: {e}")
except ConnectionError as e:
    print(f"Connection failed: {e}")
except QueryError as e:
    print(f"Query failed: {e}")
```

## Development

### Setup Development Environment

```bash
git clone https://github.com/philipdelorenzo/fuzzy-helium-meme.git
cd fuzzy-helium-meme

# Install development dependencies
pip install -e ".[dev]"
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=aurora_client

# Run specific test file
pytest tests/test_aurora_client.py
```

### Code Quality

```bash
# Format code
black aurora_client/ tests/

# Lint code
flake8 aurora_client/ tests/

# Type checking
mypy aurora_client/
```

## License

This project is released into the public domain under the [Unlicense](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
