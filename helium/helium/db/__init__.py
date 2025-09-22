import os

import motor.motor_asyncio

# MongoDB connection
if os.environ.get("MONGODB_NAME"):
    MONGODB_NAME = os.getenv("MONGODB_NAME")
else:
    print("ERROR - MONGODB_NAME not set")
    exit(1)

if os.environ.get("MONGODB_URI"):
    MONGODB_URI = os.getenv("MONGODB_URI")
else:
    print("ERROR - MONGODB_URI not set")
    exit(1)

# Let's add the APP_NAME to the MONGDB_URI
_MONGODB_URI = f"{MONGODB_URI}&appName={os.getenv('APP_NAME')}"
client = motor.motor_asyncio.AsyncIOMotorClient(_MONGODB_URI)

# Reference to the database
database = client[MONGODB_NAME]  # type: ignore -- Replace 'my_database' with your DB name/DOPPLER
