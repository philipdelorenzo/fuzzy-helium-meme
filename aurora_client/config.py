"""Configuration management for Aurora Client"""

import os
from dataclasses import dataclass
from typing import Optional
import boto3
from .exceptions import ConfigurationError


@dataclass
class AuroraConfig:
    """Configuration class for Aurora database connections"""

    host: str
    port: int = 5432
    database: str = "postgres"
    username: Optional[str] = None
    password: Optional[str] = None
    ssl_mode: str = "require"
    connect_timeout: int = 30
    region: str = "us-east-1"
    use_iam: bool = False

    @classmethod
    def from_env(cls) -> "AuroraConfig":
        """Create configuration from environment variables"""
        host = os.getenv("AURORA_HOST")
        if not host:
            raise ConfigurationError("AURORA_HOST environment variable is required")

        return cls(
            host=host,
            port=int(os.getenv("AURORA_PORT", "5432")),
            database=os.getenv("AURORA_DATABASE", "postgres"),
            username=os.getenv("AURORA_USERNAME"),
            password=os.getenv("AURORA_PASSWORD"),
            ssl_mode=os.getenv("AURORA_SSL_MODE", "require"),
            connect_timeout=int(os.getenv("AURORA_CONNECT_TIMEOUT", "30")),
            region=os.getenv("AWS_REGION", "us-east-1"),
            use_iam=os.getenv("AURORA_USE_IAM", "false").lower() == "true",
        )

    def get_connection_string(self) -> str:
        """Generate PostgreSQL connection string"""
        if self.use_iam:
            # For IAM authentication, get temporary password from AWS
            password = self._get_iam_token()
        else:
            password = self.password

        if not password:
            raise ConfigurationError(
                "Password is required when not using IAM authentication"
            )

        return (
            f"postgresql://{self.username}:{password}@{self.host}:{self.port}"
            f"/{self.database}?sslmode={self.ssl_mode}&connect_timeout={self.connect_timeout}"
        )

    def _get_iam_token(self) -> str:
        """Generate IAM authentication token for Aurora"""
        if not self.username:
            raise ConfigurationError("Username is required for IAM authentication")

        try:
            rds_client = boto3.client("rds", region_name=self.region)
            token = rds_client.generate_db_auth_token(
                DBHostname=self.host,
                Port=self.port,
                DBUsername=self.username,
                Region=self.region,
            )
            return token
        except Exception as e:
            raise ConfigurationError(f"Failed to generate IAM token: {e}")

    def validate(self) -> None:
        """Validate the configuration"""
        if not self.host:
            raise ConfigurationError("Host is required")

        if not (1 <= self.port <= 65535):
            raise ConfigurationError("Port must be between 1 and 65535")

        if not self.database:
            raise ConfigurationError("Database name is required")

        if not self.use_iam and not self.password:
            raise ConfigurationError(
                "Password is required when not using IAM authentication"
            )

        if self.use_iam and not self.username:
            raise ConfigurationError("Username is required for IAM authentication")
