# Database Connectivity

In order to connect to the PostgreSQL database, there are some key factors in Doppler that restrict the connections of undesired environments, i.e. ~> `prd`.

## Doppler Configs

SERVICE_NAME --> ex: `helium`

DOPPLER_PROJECT --> helium-api-client<br/>
DOPPLER_ENVIRONMENT --> `dev`|`stg`|`prd`<br/>
DOPPLER_CONFIG --> `${DOPPLER_ENVIRONMENT}_${SERVICE_NAME}`

### Within the main config for the environment:

DP = Doppler Project<br/>
env = Doppler Environment; i.e. ~> `dev`|`stg`|`prd`<br/>

```mermaid

---
title: Doppler Database Configuration Flow
---

flowchart LR;
    subgraph Helium
        UTC[Config Base; i.e. ~> dev] ==> AppConfig("Config - Example: <br/>dev_")
    end

    subgraph Helium AWS Aurora DB
        UTC-DB[Config Base; i.e. ~> dev_] ==>|env|VARS[
        POSTGRES_DB
        POSTGRES_HOST
        POSTGRES_PORT
        POSTGRES_USER
        POSTGRES_PASSWORD
        ] ==> aurora["Aurora Cursor"]
    end

    subgraph "Python FastAPI -- Helium<br/>"
        aurora --> FastAPI/Uvicorn
    end

    AppConfig ==> UTC-DB
```

The Application puts together the needed information for all applications to work from these two Doppler Projects.

Within those Projects, are the environments, and the particular configs for the applications in their respective swimlanes.
