from flask import Flask, render_template, jsonify

app = Flask(__name__)

PROFILE = {
    "name": "Nasir Mehmood",
    "role": "Junior DevOps Engineer",
    "status": "Open to Work",
}

@app.route("/")
def index():
    return render_template("index.html", p=PROFILE)

@app.route("/health")
def health():
    return jsonify(status="ok")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
