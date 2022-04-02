from flask import Flask
from google.cloud import spanner
import os

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World 2.0"

@app.route("/greet")
def greet():
    spanner_client = spanner.Client()
    instance = spanner_client.instance("app-test")
    database = instance.database("test-db")

    with database.snapshot() as snapshot:
        results = snapshot.execute_sql("select message from greet where msg_id=1")
        for row in results:
            return row['message']

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)
