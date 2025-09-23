from fastapi import FastAPI
from fastapi.responses import JSONResponse, RedirectResponse

# @app.on_event("startup")
# async def on_startup():
#    await create_db_and_tables()

app = FastAPI(
    title="Helium Project API",
    description="API for the Helium Project",
    contact={
            "name": "Philip De Lorenzo",
            "url": "https://github.com/philipdelorenzo",
            "email": "philip.delorenzo@gmail.com",
        }
)

@app.get("/")
async def read_root():
    return RedirectResponse("/health")


@app.get("/health")
async def health():
    return {"message": "OK!"}
