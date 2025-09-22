"""Tests for Aurora Client"""

import os
import pytest
from unittest.mock import Mock, patch, MagicMock
from aurora_client import AuroraClient, AuroraConfig
from aurora_client.exceptions import ConfigurationError, ConnectionError


class TestAuroraConfig:
    """Tests for AuroraConfig class"""

    def test_basic_config_creation(self):
        """Test basic configuration creation"""
        config = AuroraConfig(
            host="test-cluster.cluster-xyz.us-east-1.rds.amazonaws.com",
            username="testuser",
            password="testpass",
        )
        assert config.host == "test-cluster.cluster-xyz.us-east-1.rds.amazonaws.com"
        assert config.port == 5432
        assert config.database == "postgres"
        assert config.username == "testuser"
        assert config.password == "testpass"

    def test_from_env(self):
        """Test configuration from environment variables"""
        env_vars = {
            "AURORA_HOST": "test-host.amazonaws.com",
            "AURORA_PORT": "5433",
            "AURORA_DATABASE": "testdb",
            "AURORA_USERNAME": "testuser",
            "AURORA_PASSWORD": "testpass",
            "AWS_REGION": "us-west-2",
        }

        with patch.dict(os.environ, env_vars):
            config = AuroraConfig.from_env()
            assert config.host == "test-host.amazonaws.com"
            assert config.port == 5433
            assert config.database == "testdb"
            assert config.username == "testuser"
            assert config.password == "testpass"
            assert config.region == "us-west-2"

    def test_from_env_missing_host(self):
        """Test configuration from env with missing host"""
        with patch.dict(os.environ, {}, clear=True):
            with pytest.raises(
                ConfigurationError, match="AURORA_HOST environment variable is required"
            ):
                AuroraConfig.from_env()

    def test_validate_success(self):
        """Test successful validation"""
        config = AuroraConfig(
            host="test-host.amazonaws.com", username="testuser", password="testpass"
        )
        config.validate()  # Should not raise

    def test_validate_missing_host(self):
        """Test validation with missing host"""
        config = AuroraConfig(host="", username="testuser", password="testpass")
        with pytest.raises(ConfigurationError, match="Host is required"):
            config.validate()

    def test_validate_invalid_port(self):
        """Test validation with invalid port"""
        config = AuroraConfig(
            host="test-host", port=99999, username="testuser", password="testpass"
        )
        with pytest.raises(
            ConfigurationError, match="Port must be between 1 and 65535"
        ):
            config.validate()

    def test_validate_missing_password_no_iam(self):
        """Test validation with missing password and no IAM"""
        config = AuroraConfig(host="test-host", username="testuser", use_iam=False)
        with pytest.raises(
            ConfigurationError,
            match="Password is required when not using IAM authentication",
        ):
            config.validate()

    def test_connection_string_basic(self):
        """Test basic connection string generation"""
        config = AuroraConfig(
            host="test-host.amazonaws.com",
            port=5432,
            database="testdb",
            username="testuser",
            password="testpass",
        )

        conn_str = config.get_connection_string()
        expected = "postgresql://testuser:testpass@test-host.amazonaws.com:5432/testdb?sslmode=require&connect_timeout=30"
        assert conn_str == expected

    @patch("boto3.client")
    def test_iam_authentication(self, mock_boto_client):
        """Test IAM authentication token generation"""
        mock_rds_client = Mock()
        mock_rds_client.generate_db_auth_token.return_value = "iam-token-12345"
        mock_boto_client.return_value = mock_rds_client

        config = AuroraConfig(
            host="test-host.amazonaws.com",
            username="testuser",
            use_iam=True,
            region="us-east-1",
        )

        conn_str = config.get_connection_string()

        mock_boto_client.assert_called_once_with("rds", region_name="us-east-1")
        mock_rds_client.generate_db_auth_token.assert_called_once_with(
            DBHostname="test-host.amazonaws.com",
            Port=5432,
            DBUsername="testuser",
            Region="us-east-1",
        )

        expected = "postgresql://testuser:iam-token-12345@test-host.amazonaws.com:5432/postgres?sslmode=require&connect_timeout=30"
        assert conn_str == expected


class TestAuroraClient:
    """Tests for AuroraClient class"""

    def setup_method(self):
        """Set up test fixtures"""
        self.config = AuroraConfig(
            host="test-host.amazonaws.com", username="testuser", password="testpass"
        )

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_connect_success(self, mock_pool):
        """Test successful connection"""
        mock_pool_instance = Mock()
        mock_pool.return_value = mock_pool_instance

        client = AuroraClient(self.config)
        client.connect()

        mock_pool.assert_called_once()
        assert client._pool == mock_pool_instance

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_connect_failure(self, mock_pool):
        """Test connection failure"""
        mock_pool.side_effect = Exception("Connection failed")

        client = AuroraClient(self.config)

        with pytest.raises(
            ConnectionError, match="Failed to connect to Aurora database"
        ):
            client.connect()

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_context_manager(self, mock_pool):
        """Test context manager functionality"""
        mock_pool_instance = Mock()
        mock_pool.return_value = mock_pool_instance

        with AuroraClient(self.config) as client:
            assert client._pool == mock_pool_instance

        mock_pool_instance.closeall.assert_called_once()

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_execute_query_success(self, mock_pool):
        """Test successful query execution"""
        # Setup mocks
        mock_connection = Mock()
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = [{"id": 1, "name": "test"}]

        # Create a context manager mock for cursor
        cursor_context = MagicMock()
        cursor_context.__enter__.return_value = mock_cursor
        cursor_context.__exit__.return_value = None
        mock_connection.cursor.return_value = cursor_context

        mock_pool_instance = Mock()
        mock_pool_instance.getconn.return_value = mock_connection
        mock_pool.return_value = mock_pool_instance

        client = AuroraClient(self.config)
        client.connect()

        result = client.execute_query("SELECT * FROM test_table")

        assert result == [{"id": 1, "name": "test"}]
        mock_cursor.execute.assert_called_once_with("SELECT * FROM test_table", None)
        mock_cursor.fetchall.assert_called_once()

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_execute_query_with_params(self, mock_pool):
        """Test query execution with parameters"""
        mock_connection = Mock()
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = []

        # Create a context manager mock for cursor
        cursor_context = MagicMock()
        cursor_context.__enter__.return_value = mock_cursor
        cursor_context.__exit__.return_value = None
        mock_connection.cursor.return_value = cursor_context

        mock_pool_instance = Mock()
        mock_pool_instance.getconn.return_value = mock_connection
        mock_pool.return_value = mock_pool_instance

        client = AuroraClient(self.config)
        client.connect()

        params = {"user_id": 123}
        client.execute_query("SELECT * FROM users WHERE id = %(user_id)s", params)

        mock_cursor.execute.assert_called_once_with(
            "SELECT * FROM users WHERE id = %(user_id)s", {"user_id": 123}
        )

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_test_connection_success(self, mock_pool):
        """Test successful connection test"""
        mock_connection = Mock()
        mock_cursor = Mock()
        mock_cursor.fetchall.return_value = [{"test": 1}]

        # Create a context manager mock for cursor
        cursor_context = MagicMock()
        cursor_context.__enter__.return_value = mock_cursor
        cursor_context.__exit__.return_value = None
        mock_connection.cursor.return_value = cursor_context

        mock_pool_instance = Mock()
        mock_pool_instance.getconn.return_value = mock_connection
        mock_pool.return_value = mock_pool_instance

        client = AuroraClient(self.config)

        result = client.test_connection()

        assert result is True
        mock_cursor.execute.assert_called_once_with("SELECT 1 as test", None)

    @patch("aurora_client.client.ThreadedConnectionPool")
    def test_test_connection_failure(self, mock_pool):
        """Test connection test failure"""
        mock_connection = Mock()
        mock_cursor = Mock()
        mock_cursor.execute.side_effect = Exception("Connection failed")

        # Create a context manager mock for cursor
        cursor_context = MagicMock()
        cursor_context.__enter__.return_value = mock_cursor
        cursor_context.__exit__.return_value = None
        mock_connection.cursor.return_value = cursor_context

        mock_pool_instance = Mock()
        mock_pool_instance.getconn.return_value = mock_connection
        mock_pool.return_value = mock_pool_instance

        client = AuroraClient(self.config)

        result = client.test_connection()

        assert result is False
