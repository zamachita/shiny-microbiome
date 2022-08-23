from pydantic import BaseSettings

class Settings(BaseSettings):
    work_dir: str = 'static/upload/'
    accept_csv: str = '.csv'
    accept_fa: str = '.gz'
    file_accept: str = 'csv,gz'

settings = Settings()