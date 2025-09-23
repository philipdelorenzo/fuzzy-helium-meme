import os
import psycopg2

from typing import Any

# PostgreSQL connection
# These variables are coming from Doppler secrets manager
# If the Doppler token is not set, or available, or correct, the application will not starts
if os.environ.get("POSTGRES_HOST"):
    POSTGRES_HOST = os.getenv("POSTGRES_HOST")
else:
    print("ERROR - POSTGRES_HOST not set")
    exit(1)

if os.environ.get("POSTGRES_PORT"):
    POSTGRES_PORT = os.getenv("POSTGRES_PORT")
else:
    print("ERROR - POSTGRES_PORT not set")
    exit(1)

if os.environ.get("POSTGRES_DB"):
    POSTGRES_DB = os.getenv("POSTGRES_DB")
else:
    print("ERROR - POSTGRES_DB not set")
    exit(1)

if os.environ.get("POSTGRES_USER"):
    POSTGRES_USER = os.getenv("POSTGRES_USER")
else:
    print("ERROR - POSTGRES_USER not set")
    exit(1)

if os.environ.get("POSTGRES_PASSWORD"):
    POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD")
else:
    print("ERROR - POSTGRES_PASSWORD not set")
    exit(1)

try:
    # Establishing the connection
    # These variables are coming from Doppler secrets manager
    conn = psycopg2.connect(
        host=POSTGRES_HOST,
        user=POSTGRES_USER,
        password=POSTGRES_PASSWORD,
        database=POSTGRES_DB,
        port=POSTGRES_PORT
    )
    
    # Create a cursor object to execute queries
    with conn.cursor() as cursor:
        cursor.execute("SELECT version()")
        db_version: Any = cursor.fetchone()
        print(f"Connected to Aurora PostgreSQL. Database version: {db_version[0]}")

except psycopg2.Error as e:
    print(f"Failed to connect to the database: {e}")

finally:
    if 'conn' in locals() and not conn.closed:
        conn.close()
        print("Database connection closed.")
