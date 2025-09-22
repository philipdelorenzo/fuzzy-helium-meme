"""
Aurora Client - A simple PostgreSQL client for AWS Aurora
"""

__version__ = "0.1.0"
__author__ = "Philip De Lorenzo"
__email__ = "philip@example.com"

from .client import AuroraClient
from .config import AuroraConfig
from .exceptions import AuroraClientError, ConnectionError, QueryError

__all__ = [
    "AuroraClient",
    "AuroraConfig",
    "AuroraClientError",
    "ConnectionError",
    "QueryError",
]
