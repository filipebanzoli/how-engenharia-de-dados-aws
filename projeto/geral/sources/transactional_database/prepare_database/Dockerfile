# Dockerfile, Image, Container
FROM python:3.11-slim

WORKDIR /app

# Add current folder to docker image
COPY . .

# upgrade pip and install pip packages
RUN pip install --no-cache-dir -r requirements.txt

# run python program
CMD ["python", "main.py"]
