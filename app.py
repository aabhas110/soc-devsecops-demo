from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return {
        "message": "SOC DevSecOps Demo App",
        "status": "running"
    }

@app.route("/health")
def health():
    return {
        "status": "OK"
    }, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
