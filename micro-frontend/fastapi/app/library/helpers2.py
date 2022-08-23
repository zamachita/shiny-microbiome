import os.path
import uuid
from pathlib import Path

from app.config import settings

def create_workspace():
    """
    Return workspace path
    """
    # base directory
    work_dir = Path(settings.work_dir)
    # UUID to prevent file overwrite
    request_id = Path(str(uuid.uuid4())[:16])
    # path concat instead of work_dir + '/' + request_id
    workspace = work_dir / request_id
    if not os.path.exists(workspace):
        # recursively create workdir/unique_id
        os.makedirs(workspace)

    return workspace