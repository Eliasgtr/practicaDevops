"""
Aplicación web "Hola Mundo" en Python con Flask.
DevOps practice - 2026
"""
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/")
def hola_mundo():
    """Devuelve un saludo en texto plano."""
    return "¡Hola Mundo! - DevOps Practice 2026"


@app.route("/health")
def health():
    """Endpoint de health check para Kubernetes / load balancers."""
    return jsonify({"status": "ok", "service": "hola-mundo-devops"})


@app.route("/info")
def info():
    """Endpoint informativo con metadata de la app."""
    return jsonify({
        "app": "hola-mundo",
        "version": "1.0.0",
        "language": "Python",
        "framework": "Flask"
    })


if __name__ == "__main__":
    # 0.0.0.0 para que sea accesible desde fuera del contenedor
    app.run(host="0.0.0.0", port=5000, debug=False)
# hola-mundo-devops
