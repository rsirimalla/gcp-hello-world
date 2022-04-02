FROM python:3.7

COPY . /app
WORKDIR /app
RUN pip install flask

ENTRYPOINT ["python"]
CMD ["app.py"]