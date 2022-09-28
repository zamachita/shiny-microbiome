from typing import List
from fastapi import Request, Form, APIRouter, File, UploadFile, status
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from app.library.helpers2 import *

import os.path
import uuid
from pathlib import Path
from app.config import settings

router = APIRouter()
templates = Jinja2Templates(directory="templates/")


@router.get("/upload", response_class=HTMLResponse)
def get_upload(request: Request):
    result = "Hello from upload.py"
    proj_id = Path(str(uuid.uuid4())[:16])
    return templates.TemplateResponse('upload.html', context={'request': request, 'result': result, 'proj_id': proj_id})
