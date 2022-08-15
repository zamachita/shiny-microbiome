from pydantic import BaseSettings

class Settings(BaseSettings):
    work_dir: str = 'upload/'
    accept_csv: str = '.csv'
    accept_fa: str = '.gz'

settings = Settings()