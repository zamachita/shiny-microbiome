from typing import List
from fastapi import Request, Form, APIRouter, File, UploadFile, status
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from app.library.helpers2 import *

router = APIRouter()
templates = Jinja2Templates(directory="templates/")


@router.get("/project", response_class=HTMLResponse)
def create_project(request: Request):
    result = "Project Started"
    print(result)
    return templates.TemplateResponse('project.html', context={'request': request, 'result': result})

# @router.

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
