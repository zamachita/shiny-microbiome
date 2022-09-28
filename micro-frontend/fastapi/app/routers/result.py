import os
from fastapi import Request, APIRouter, Depends
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates

from dotenv import load_dotenv
load_dotenv()

templates = Jinja2Templates(directory="templates")

router = APIRouter()


@router.get("/result", response_class=HTMLResponse)
async def unsplash_home(request: Request):
    return templates.TemplateResponse("result-demo.html", {"request": request})
