# Ensaio S Correção 2.0 — Azure Container Apps (campo live + OTA)
FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=80 \
    ENSAIOS_DATA_DIR=/app/data \
    ENSAIOS_SHARE_DIR=/home/data \
    ENSAIO_MODO=live \
    PREPARAR_OTA=1 \
    ESCRITORIO_SENHA=ambev2026

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p /home/data /app/data /home/data/secrets

EXPOSE 80

CMD ["sh", "-c", "gunicorn -b 0.0.0.0:${PORT:-80} --workers 1 --threads 4 --timeout 120 app:app"]
