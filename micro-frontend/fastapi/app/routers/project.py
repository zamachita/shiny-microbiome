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


@router.get("/project", response_class=HTMLResponse)
def get_upload(request: Request):
    result = "Hello from upload.py"
    proj_id = Path(str(uuid.uuid4())[:16])
    return templates.TemplateResponse('new_project.html', context={'request': request, 'result': result, 'proj_id': proj_id})

@router.post("/upload/test/{proj_id}", response_class=JSONResponse)
async def get_upload(file: UploadFile, proj_id: str):
    print(f"Uploading file: {file.filename}")

    # base directory
    work_dir = Path(settings.work_dir)
    # path concat instead of work_dir + '/' + request_id
    workspace = work_dir / proj_id
    if not os.path.exists(workspace):
        # recursively create workdir/unique_id
        os.makedirs(workspace)

    file_path = Path(file.filename)
    # file full path
    file_full_path = workspace / file_path
    try:
        with open(str(file_full_path), 'wb') as myfile:
            contents = await file.read()
            myfile.write(contents)
    except Exception:
        # print("ERROR" + Exception)
        return {"message": "There was an error uploading the file(s) [{file_full_path}]"}
    finally:
        file.file.close()
    
    print(f"Project ID: {proj_id}")
    print(f"Uploaded file to: {file_full_path}")

    return {"filename": file.filename}

@router.post("/upload/test_multiple", response_class=JSONResponse)
async def create_upload_files(files: List[UploadFile]):
    return {f"filename": {[file.filename for file in files]}}

@router.post("/upload/files", response_class=JSONResponse)
def post_upload_files(files: List[UploadFile] = File(...)):
    """
    multiple uploads
    """
    print(f"Input File(s): {[file.filename for file in files]}")
    # create the full path
    workspace = create_workspace()

    for file in files:
        # filename
        file_path = Path(file.filename)
        # file full path
        file_full_path = workspace / file_path
        try:
            with open(str(file_full_path), 'wb') as myfile:
                contents = file.read()
                myfile.write(contents)
        except Exception:
            print("ERROR" + Exception)
            return {"message": "There was an error uploading the file(s) [{file_full_path}]"}
        finally:
            file.file.close()
    return {"filenames": [file.filename for file in files]}


@router.post("/upload/new")
async def post_upload(files: List[UploadFile] = File(...)):
    """
    multiple uploads
    """
    print(f"Input File(s): {[file.filename for file in files]}")
    # create the full path
    workspace = create_workspace()

    for file in files:
        # filename
        file_path = Path(file.filename)
        # file full path
        file_full_path = workspace / file_path
        try:
            with open(str(file_full_path), 'wb') as myfile:
                contents = await file.read()
                myfile.write(contents)
        except Exception:
            print("ERROR" + Exception)
            return {"message": "There was an error uploading the file(s) [{file_full_path}]"}
        finally:
            file.file.close()


    # for file in files:
    #     try:
    #         with open(file.filename, 'wb') as f:
    #             while contents := file.file.read(1024):
    #                 f.write(contents)
    #     except Exception:
    #         return {"message": "There was an error uploading the file(s)"}
    #     finally:
    #         file.file.close()
    # return {"filenames": [file.filename for file in files]}
    # return {"message": f"Successfuly uploaded {[file.filename for file in files]}", "workspace": f"{workspace}", "uuid": f"{str(workspace.cwd)}"}  
    # return 1
    print(status.HTTP_200_OK)
    return JSONResponse(
            status_code = status.HTTP_200_OK,
            content = {"result":'success'}
            )
