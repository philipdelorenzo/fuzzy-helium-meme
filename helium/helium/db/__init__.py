import os
import asyncio
from typing import Any
from sqlalchemy import text
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
# In a file like helium/dependencies.py
from sqlalchemy.orm import Session

from helium.models.contact import Base

__local = True
port = 5432
db_port = int(os.getenv("POSTGRES_PORT", port))

# Our application needs to ensure that we can connect to the database
if not os.environ.get("AURORA_DATABASE_HOST_READ"):
    print("ERROR - AURORA_DATABASE_HOST_READ not set")
    exit(1)
else:
    read_host = os.getenv("AURORA_DATABASE_HOST_READ")

if not os.environ.get("AURORA_DATABASE_HOST_WRITE"):
    print("ERROR - AURORA_DATABASE_HOST_WRITE not set")
    exit(1)
else:
    write_host = os.getenv("AURORA_DATABASE_HOST_WRITE")

# PostgreSQL connection
# These variables are coming from Doppler secrets manager
# If the Doppler token is not set, or available, or correct, the application will not starts
if not os.environ.get("TF_VAR_DB_NAME"):
    print("ERROR - TF_VAR_DB_NAME not set")
    exit(1)
else:
    db_name = os.getenv("TF_VAR_DB_NAME")

if not os.environ.get("TF_VAR_DB_USERNAME"):
    print("ERROR - TF_VAR_DB_USERNAME not set")
    exit(1)
else:
    db_username = os.getenv("TF_VAR_DB_USERNAME")

if not os.environ.get("TF_VAR_DB_PASSWORD"):
    print("ERROR - TF_VAR_DB_PASSWORD not set")
    exit(1)
else:
    db_password = os.getenv("TF_VAR_DB_PASSWORD")

# Read connection
try:
    # Establishing the connection
    # These variables are coming from Doppler secrets manager
    if globals()["__local"]:
        _url = f"postgresql+asyncpg://postgres:postgres@localhost:5432/postgres"
    else:
        _url = f"postgresql+asyncpg://{db_username}:{db_password}@{read_host}:{db_port}/{db_name}"

    read_conn = create_async_engine(
        _url,
        echo=True
    )
    
except Exception as e:
    print(f"Failed to connect to the database: {e}")
    exit(1)

# Write connection
try:
    # Establishing the connection
    # These variables are coming from Doppler secrets manager
    if __local:
        _url = f"postgresql+asyncpg://postgres:postgres@localhost:5432/postgres"
    else:
        _url = f"postgresql+asyncpg://{db_username}:{db_password}@{write_host}:{db_port}/{db_name}"

    write_conn = create_async_engine(
        _url,
        echo=True
    )

except Exception as e:
    print(f"Failed to connect to the database: {e}")
    exit(1)

async def create_tables():
    async with write_conn.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

async def drop_tables():
    """
    Drops all tables defined in Base.metadata.
    
    This function uses a connection from the write_conn engine
    and calls the drop_all method on the Base's metadata.
    """
    async with write_conn.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

async def get_read_db():
    """
    Dependency to provide an async read-only database session.
    The 'async with' statement handles the session cleanup automatically.
    """
    async with AsyncSession(read_conn) as db:
        yield db

async def get_write_db():
    """
    Dependency to provide an async writeable database session.
    The 'async with' statement handles the session cleanup automatically.
    """
    async with AsyncSession(write_conn) as db:
        yield db
