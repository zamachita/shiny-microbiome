# Before start
> pip install -r requirements.txt

# to start server
# if can run uvicorn directly, please run
> uvicorn main:app --reload --port 8000

# if can't run uvicorn directly, please use python3 or python
> python -m uvicorn main:app --reload --port 8000

# open the browser
http://localhost:8000