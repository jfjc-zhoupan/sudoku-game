"""Web Sudoku app. Puzzle generation stays in Python; the browser plays the game."""

from flask import Flask, jsonify, render_template, request

from engine import DIFFICULTY, new_puzzle

__version__ = "1.0.0"  # Follows Semantic Versioning (major.minor.patch)

app = Flask(__name__)

@app.get("/")
def index():
    return render_template("index.html", difficulties=list(DIFFICULTY.keys()))


@app.post("/api/new")
def api_new():
    data = request.get_json(silent=True) or {}
    difficulty = data.get("difficulty", "Easy")
    if difficulty not in DIFFICULTY:
        difficulty = "Easy"
    puzzle, solution = new_puzzle(difficulty)
    empty = sum(1 for row in puzzle for cell in row if cell == 0)
    return jsonify(
        {
            "difficulty": difficulty,
            "puzzle": puzzle,
            "solution": solution,
            "empty": empty,
        }
    )

@app.get("/api/version")
def api_version():
    return jsonify({
        "version":__version__,
        "app_name":"Sudoku Game"
    })


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
