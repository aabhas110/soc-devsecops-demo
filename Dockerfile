FROM python:3.11-slim

WORKDIR /app

# Install curl for health checks
RUN apt-get update && apt-get install -y curl

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

CMD ["python", "app.py"]