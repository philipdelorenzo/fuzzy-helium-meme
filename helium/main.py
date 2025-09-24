import os
import argparse

import uvicorn

service_name = "helium"
HOST = "0.0.0.0"
PORT = os.getenv("PORT", 8000)

global __local
__local = False # Default to False, will be set to True if --local is passed

args = argparse.ArgumentParser()
args.add_argument("--local", action="store_true", default=HOST, help="Pass this to set the environment to local.")

parser = args.parse_args()
if parser.local:
    __local = True

if isinstance(PORT, str):
    PORT = int(PORT)

if __name__ == "__main__":
    uvicorn.run(
        f"{service_name}.app:app",
        host=HOST,
        port=PORT,
        reload=True,
        log_level="info",
    )
