from importlib.resources import contents
from pathlib import Path
from typing import List

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import HTMLResponse

from library.helpers import create_workspace

app = FastAPI()


@app.post("/files/")
async def create_files(
    files: List[bytes] = File(description="Multiple files as bytes"),
):
    return {"file_sizes": [len(file) for file in files]}


@app.post("/uploadfiles/")
async def create_upload_files(
    files: List[UploadFile] = File(description="Multiple files as UploadFile"),
):
    return {"filenames": [file.filename for file in files]}

@app.post("/upload")
async def upload(file: UploadFile = File(...)):
    try:
        with open(file.filename, 'wb') as f:
            while contents := file.file.read(1024):
                f.write(contents)
    except Exception:
        return {"message": "There was an error uploading the file"}
    finally:
        file.file.close()

    return {"message": f"Successfully uploaded {file.filename}"}

@app.post("/uploads")
async def uploads(files: List[UploadFile] = File(...)):
    """
    multiple uploads
    """

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
    print(workspace.absolute)        
    print(workspace.home)
    return {"message": f"Successfuly uploaded {[file.filename for file in files]}", "workspace": f"{workspace}", "uuid": f"{str(workspace.cwd)}"}  


@app.get("/")
async def main():
    content = """
<body>
Metadata & Fasta.gz Files Upload (/uploads)
<form action="/uploads/" enctype="multipart/form-data" method="post">
<input name="files" type="file" multiple>
<input type="submit">
</form>
</body>
    """
    return HTMLResponse(content=content)

