"""Custom exceptions for Aurora Client"""


class AuroraClientError(Exception):
    """Base exception for Aurora Client errors"""

    pass


class ConnectionError(AuroraClientError):
    """Exception raised when connection to Aurora fails"""

    pass


class QueryError(AuroraClientError):
    """Exception raised when query execution fails"""

    pass


class ConfigurationError(AuroraClientError):
    """Exception raised when configuration is invalid"""

    pass
