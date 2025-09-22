import os

import uvicorn

service_name = "helium"
HOST = "0.0.0.0"
PORT = os.getenv("PORT", 8000)

if type(PORT) == str:
    PORT = int(PORT)

if __name__ == "__main__":
    if os.path.isfile(os.path.join("/", ".dockerenv")):
        uvicorn.run(
            f"{service_name}.app:app",
            host=HOST,
            port=PORT,
            reload=True,
            log_level="info",
        )
    else:
        uvicorn.run(
            f"{service_name}.app:app",
            host=HOST,
            port=PORT,
            reload=True,
            log_level="info",
        )
