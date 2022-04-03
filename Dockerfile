FROM python:3.7

COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY ./app /app
WORKDIR /app

ENTRYPOINT ["python"]
CMD ["app.py"]