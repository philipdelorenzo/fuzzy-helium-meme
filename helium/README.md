# Helium API Client --> Aurora AWS RDS

Welcome to the Helium API Client that securely connects you to an AWS Aurora database instance for persistent data.

## STOP!

If you haven't run the initialization command with `make` yet, please do so now...

## Helium API Client

The Helium API Client application is built with Python, [Poetry](https://python-poetry.org/), and [Uvicorn](https://uvicorn.dev/) _(Application Server)_.

### Health Check

To ensure the health of the application, there is an endpoint that responds with a `{"message":"OK!"}` when accessing the root:

`http://localhost:8000`

To view the interactive Swagger documentation:

`http://localhost:8000/docs`


## Docker Build

To run the Docker build, you can run the command directly:

```bash
## You will need to build the requirements file for production --
## This is an export of the Poetry data, so it will keep our Docker image lighter
# From the root of the repo
cd helium || exit 1 && ./../.python/bin/poetry export -f requirements.txt --without-hashes -o production.txt

# Now let's build our image
cd helium || exit 1 && docker build -t fuzzyheliummeme/${service}:latest .
```

## _TL;DR Developer Experience_

```bash
# From the root of the repo
make build
```

To run your newly built Docker image:

```bash
docker run -it -p 8000:8000 --rm docker.io/fuzzyheliummeme/helium:latest
```

Back to [Health Check](#health-check)
