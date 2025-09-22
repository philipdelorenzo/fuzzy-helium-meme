"""Main Aurora Client implementation"""

import logging
from contextlib import contextmanager
from typing import Any, Dict, List, Optional, Union, Generator
import psycopg2
from psycopg2.pool import ThreadedConnectionPool
from psycopg2.extras import RealDictCursor

from .config import AuroraConfig
from .exceptions import ConnectionError, QueryError


logger = logging.getLogger(__name__)


class AuroraClient:
    """A simple PostgreSQL client for AWS Aurora"""

    def __init__(
        self, config: AuroraConfig, pool_size: int = 5, max_connections: int = 20
    ):
        """
        Initialize Aurora client

        Args:
            config: Aurora configuration
            pool_size: Minimum number of connections in pool
            max_connections: Maximum number of connections in pool
        """
        self.config = config
        self.config.validate()
        self._pool: Optional[ThreadedConnectionPool] = None
        self.pool_size = pool_size
        self.max_connections = max_connections

    def connect(self) -> None:
        """Establish connection pool to Aurora database"""
        try:
            connection_string = self.config.get_connection_string()
            self._pool = ThreadedConnectionPool(
                minconn=self.pool_size,
                maxconn=self.max_connections,
                dsn=connection_string,
            )
            logger.info(
                f"Connected to Aurora database at {self.config.host}:{self.config.port}"
            )
        except Exception as e:
            raise ConnectionError(f"Failed to connect to Aurora database: {e}")

    def disconnect(self) -> None:
        """Close all connections in the pool"""
        if self._pool:
            self._pool.closeall()
            self._pool = None
            logger.info("Disconnected from Aurora database")

    @contextmanager
    def get_connection(self) -> Generator[psycopg2.extensions.connection, None, None]:
        """
        Context manager for getting database connection from pool

        Yields:
            Database connection from pool
        """
        if not self._pool:
            self.connect()

        connection = None
        try:
            connection = self._pool.getconn()
            yield connection
        except Exception as e:
            if connection:
                connection.rollback()
            raise QueryError(f"Database operation failed: {e}")
        finally:
            if connection:
                self._pool.putconn(connection)

    def execute_query(
        self,
        query: str,
        params: Optional[Union[tuple, dict]] = None,
        fetch: bool = True,
        cursor_factory: Optional[Any] = RealDictCursor,
    ) -> Optional[List[Dict[str, Any]]]:
        """
        Execute a SQL query

        Args:
            query: SQL query to execute
            params: Query parameters
            fetch: Whether to fetch results
            cursor_factory: Cursor factory to use

        Returns:
            Query results if fetch is True, None otherwise
        """
        with self.get_connection() as conn:
            with conn.cursor(cursor_factory=cursor_factory) as cursor:
                try:
                    cursor.execute(query, params)

                    if fetch:
                        return cursor.fetchall()
                    else:
                        conn.commit()
                        return None

                except Exception as e:
                    conn.rollback()
                    raise QueryError(f"Query execution failed: {e}")

    def execute_many(self, query: str, params_list: List[Union[tuple, dict]]) -> None:
        """
        Execute a query multiple times with different parameters

        Args:
            query: SQL query to execute
            params_list: List of parameter sets
        """
        with self.get_connection() as conn:
            with conn.cursor() as cursor:
                try:
                    cursor.executemany(query, params_list)
                    conn.commit()
                except Exception as e:
                    conn.rollback()
                    raise QueryError(f"Batch execution failed: {e}")

    def begin_transaction(self) -> "Transaction":
        """Begin a new transaction"""
        return Transaction(self)

    def test_connection(self) -> bool:
        """
        Test database connectivity

        Returns:
            True if connection is successful, False otherwise
        """
        try:
            result = self.execute_query("SELECT 1 as test")
            return result is not None and len(result) > 0 and result[0]["test"] == 1
        except Exception as e:
            logger.error(f"Connection test failed: {e}")
            return False

    def get_server_version(self) -> str:
        """
        Get PostgreSQL server version

        Returns:
            Server version string
        """
        result = self.execute_query("SELECT version() as version")
        if result and len(result) > 0:
            return result[0]["version"]
        return "Unknown"

    def __enter__(self):
        """Context manager entry"""
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.disconnect()


class Transaction:
    """Transaction context manager"""

    def __init__(self, client: AuroraClient):
        self.client = client
        self.connection = None

    def __enter__(self):
        self.connection = self.client._pool.getconn()
        self.connection.autocommit = False
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        try:
            if exc_type is None:
                self.connection.commit()
            else:
                self.connection.rollback()
        finally:
            self.client._pool.putconn(self.connection)

    def execute(
        self,
        query: str,
        params: Optional[Union[tuple, dict]] = None,
        fetch: bool = True,
        cursor_factory: Optional[Any] = RealDictCursor,
    ) -> Optional[List[Dict[str, Any]]]:
        """Execute query within transaction"""
        with self.connection.cursor(cursor_factory=cursor_factory) as cursor:
            cursor.execute(query, params)
            if fetch:
                return cursor.fetchall()
            return None
