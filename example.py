#!/usr/bin/env python3
"""
Example usage of the Aurora Client

This script demonstrates how to use the Aurora Client to connect to AWS Aurora
and perform basic database operations.
"""

import os
import sys
from aurora_client import AuroraClient, AuroraConfig


def main():
    """Main example function"""
    
    # Example 1: Create configuration from environment variables
    print("=== Aurora Client Example ===")
    
    try:
        # Load configuration from environment variables
        # Make sure to set: AURORA_HOST, AURORA_USERNAME, AURORA_PASSWORD
        config = AuroraConfig.from_env()
        print(f"✓ Configuration loaded for host: {config.host}")
    except Exception as e:
        print(f"❌ Failed to load configuration: {e}")
        print("\nPlease set the following environment variables:")
        print("  AURORA_HOST - Aurora cluster endpoint")
        print("  AURORA_USERNAME - Database username")
        print("  AURORA_PASSWORD - Database password (or use AURORA_USE_IAM=true)")
        print("  AURORA_DATABASE - Database name (optional, defaults to 'postgres')")
        return 1
    
    # Example 2: Using the client with context manager
    try:
        with AuroraClient(config) as client:
            print("✓ Connected to Aurora database")
            
            # Test the connection
            if client.test_connection():
                print("✓ Connection test successful")
                
                # Get server version
                version = client.get_server_version()
                print(f"✓ Server version: {version}")
                
                # Example query - get current timestamp
                result = client.execute_query("SELECT NOW() as current_time")
                if result:
                    print(f"✓ Current time: {result[0]['current_time']}")
                
                # Example of creating a table and inserting data
                # (This is just an example - modify as needed)
                try:
                    # Create a simple test table
                    client.execute_query("""
                        CREATE TABLE IF NOT EXISTS test_users (
                            id SERIAL PRIMARY KEY,
                            name VARCHAR(100) NOT NULL,
                            email VARCHAR(100) UNIQUE NOT NULL,
                            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                        )
                    """, fetch=False)
                    print("✓ Test table created")
                    
                    # Insert some test data
                    client.execute_query("""
                        INSERT INTO test_users (name, email) 
                        VALUES (%(name)s, %(email)s)
                        ON CONFLICT (email) DO NOTHING
                    """, {
                        "name": "Test User",
                        "email": "test@example.com"
                    }, fetch=False)
                    print("✓ Test data inserted")
                    
                    # Query the data
                    users = client.execute_query("SELECT * FROM test_users LIMIT 5")
                    print(f"✓ Found {len(users)} users:")
                    for user in users:
                        print(f"  - {user['name']} ({user['email']})")
                
                except Exception as e:
                    print(f"⚠️  Table operation failed (this is normal if you don't have permissions): {e}")
                
            else:
                print("❌ Connection test failed")
                return 1
                
    except Exception as e:
        print(f"❌ Client error: {e}")
        return 1
    
    print("\n=== Example completed successfully ===")
    return 0


if __name__ == "__main__":
    sys.exit(main())