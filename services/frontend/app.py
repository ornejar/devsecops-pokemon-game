from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "frontend service for Pokemon game is running!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
