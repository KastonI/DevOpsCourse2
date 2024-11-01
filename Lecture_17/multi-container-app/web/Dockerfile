
FROM python:3.11-alpine AS builder

WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

FROM python:3.11-alpine

WORKDIR /app

COPY --from=builder /app /app

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "app.py"]
