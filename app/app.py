from flask import Flask
from google.cloud import spanner
import os

app = Flask(__name__)

@app.route("/")
def greet():
    spanner_client = spanner.Client()
    instance = spanner_client.instance("app-test")
    database = instance.database("test-db")

    data = "No one to greet here"
    with database.snapshot() as snapshot:
        results = snapshot.execute_sql("select message from greet where msg_id=1")
        for row in results:
            data = row[0]
    return data
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)
