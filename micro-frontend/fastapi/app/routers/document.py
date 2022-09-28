from fastapi import FastAPI, Request, Form, APIRouter
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
import os

router = APIRouter()
templates = Jinja2Templates(directory="templates/")


@router.get("/tutorial", response_class=HTMLResponse)
def form_get(request: Request):
    return templates.TemplateResponse('tutorial.html', context={'request': request})


