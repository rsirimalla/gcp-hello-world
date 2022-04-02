FROM python:3.7

COPY . /app
WORKDIR /app
RUN pip install flask google-cloud-spanner

ENTRYPOINT ["python"]
CMD ["app.py"]