from flask import Flask
from google.cloud import spanner
import os

app = Flask(__name__)

@app.route("/")
def greet():
    spanner_client = spanner.Client()
    instance = spanner_client.instance("app-test")
    database = instance.database("test-db")

    with database.snapshot() as snapshot:
        results = snapshot.execute_sql("select message from greet where msg_id=1")
        if len(results) == 1:
            return results[0][0]
        else:
            return "No one to geet you at the moment"        

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)
