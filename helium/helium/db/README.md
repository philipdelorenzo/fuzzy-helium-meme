# Database Connectivity

In order to connect to the MongoDB database, there are some key factors in Doppler that restrict the connections of undesired environments, i.e. ~> `prd`.

## Doppler Configs

SERVICE_NAME --> ex: `utcore-hoa`

DOPPLER_PROJECT --> unitytree-core<br/>
DOPPLER_ENVIRONMENT --> `dev`|`stg`|`prd`<br/>
DOPPLER_CONFIG --> `${DOPPLER_ENVIRONMENT}_${SERVICE_NAME}`

### Within the main config for the environment:

DP = Doppler Project<br/>
env = Doppler Environment; i.e. ~> `dev`|`stg`|`prd`<br/>
MONGODB_URI = `mongodb+srv://${unitytree-core-database.<DOPPLER_ENVIRONMENT>.MONGODB_USER}:${unitytree-core-database.<DOPPLER_ENVIRONMENT>.MONGODB_PASS}@${unitytree-core-database.dev.MONGODB_NAME}.${unitytree-core-database.<DOPPLER_ENVIRONMENT>.DATABASE_ID}.mongodb.net/?retryWrites=true&w=majority`

_MONGODB_URI = `f"{MONGODB_URI}&appname={APP_NAME}"`

```mermaid

---
title: Doppler Database Configuration Flow
---

flowchart LR;
    subgraph unitytree-core
        UTC[Config Base; i.e. ~> dev] ==> AppConfig("Config - Example: <br/>dev_utcore-hoa")
        UTC
        utcConfig["Config:<br/>MONGODB_URI
        --
        See MONGODB_URI above"]
    end
    subgraph unitytree-core-database
        UTC-DB[Config Base; i.e. ~> dev] ==>|env|VARS[
        DATABASE_ID
        MONGO_DB_NAME
        MONGODB_USER
        MONGODB_PASS
        ] ==> utcConfig
    end

    subgraph "Python FastAPI<br/>Example: utcore-hoa"
        utcConfig ==> _MONGODB_URI["See Above:<br/>_MONGODB_URI"]
    end

    AppConfig ==> UTC-DB
```

The Application puts together the needed information for all applications to work from these two Doppler Projects.

Within those Projects, are the environments, and the particular configs for the applications in their respective swimlanes.
