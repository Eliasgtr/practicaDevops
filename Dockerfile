# Imagen ligera basada en Python 3.11 slim (Debian)
FROM python:3.11-slim

# Metadata
LABEL maintainer="edgardo-devops"
LABEL description="Hola Mundo - DevOps Practice"
LABEL version="1.0.0"

# Variables de entorno para que Python no genere .pyc y los logs salgan sin buffer
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=5000

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Primero copiamos solo requirements para aprovechar la caché de capas de Docker
COPY requirements.txt .

# Instalamos dependencias (sin cache de pip para reducir tamaño)
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el resto del código
COPY app.py .

# Documenta el puerto que usa la app
EXPOSE 5000

# Usuario no-root por seguridad
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Comando de arranque: gunicorn para producción (2 workers, bind 0.0.0.0:5000)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
