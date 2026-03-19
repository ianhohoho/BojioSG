from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from database import Base, engine, SQLALCHEMY_DATABASE_URL
from routers import auth_router, events_router, notifications_router

# Only auto-create tables for local SQLite; Supabase tables managed via migrations
if SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
    Base.metadata.create_all(bind=engine)

app = FastAPI(title="BojioSG API", version="1.0.0")

# CORS for local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(events_router.router)
app.include_router(notifications_router.router)


@app.get("/")
def root():
    return {"message": "BojioSG API", "docs": "/docs"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
