
from typing import List, Union #, Any, Dict, Optional

from fastapi import FastAPI, APIRouter
from fastapi.responses import JSONResponse
from fastapi.exceptions import HTTPException
from starlette.middleware.cors import CORSMiddleware
from pydantic import BaseModel, AnyHttpUrl, BaseSettings, validator #, EmailStr, HttpUrl, PostgresDsn

from calc.calc import calculate


class Settings(BaseSettings):

    DEBUG_BACKEND: bool = False

    # SERVER_NAME: str
    # SERVER_HOST: AnyHttpUrl

    API_V1_STR: str = "/api/v1"

    # BACKEND_CORS_ORIGINS is a JSON-formatted list of origins
    # e.g: '["http://localhost", "http://localhost:4200", "http://localhost:3000", \
    # "http://localhost:8080", "http://local.dockertoolbox.tiangolo.com"]'
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @validator("BACKEND_CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    PROJECT_NAME: str = "bank-leumi-ccoe-test/simple-expression-calculator"

    class Config:
        case_sensitive = True

class ExpressionSchema(BaseModel):
    expr: str

api_router = APIRouter()

@api_router.post("/calc", response_class=JSONResponse)
async def calc_expr(expr: ExpressionSchema):
    try:
        res = calculate(expr.expr, debug=settings.DEBUG_BACKEND)
        return {
            "result": res
        }
    
    except Exception as e:
        raise HTTPException(400, str(e))


settings = Settings()

app = FastAPI(
    title=settings.PROJECT_NAME, 
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/"
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(api_router, prefix=settings.API_V1_STR)


if __name__ == '__main__':
    from uvicorn import run
    from os import environ

    run(app, host=environ.get("HOST", "0.0.0.0"), port=int(environ.get("PORT", 8000)))

