from fastapi import FastAPI
from fastapi.responses import JSONResponse, RedirectResponse

import helium.db
from helium.routes.contact import router as contact_router

app = FastAPI(
    title="Helium Project API",
    description="API for the Helium Project",
    contact={
            "name": "Philip De Lorenzo",
            "url": "https://github.com/philipdelorenzo",
            "email": "philip.delorenzo@gmail.com",
        }
)

@app.on_event("startup")
async def on_startup():
   await helium.db.create_tables()

@app.get("/")
async def read_root():
    return RedirectResponse("/health")


@app.get("/health")
async def health():
    return {"message": "OK!"}

app.include_router(contact_router, prefix="/contacts", tags=["contacts"])
