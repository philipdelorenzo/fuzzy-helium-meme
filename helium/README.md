# Helium API Client --> Aurora AWS RDS

Welcome to the Helium API Client that securely connects you to an AWS Aurora database instance for persistant data.

## STOP!

If you haven't run the initialization command with `make` yet, please do so now...

## Helium API Client

The Helium API Client application is built with Python, [Poetry](https://python-poetry.org/), and [Uvicorn](https://uvicorn.dev/) _(Application Server)_.

### Health Check

To ensure the health of the application, there is an endpoint that responds with a `{"message":"OK!"}` when accessing the root:

`http://localhost:8000`
