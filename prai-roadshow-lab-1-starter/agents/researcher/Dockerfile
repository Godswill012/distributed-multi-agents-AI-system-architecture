FROM python:3.11-slim
ENV PYTHONUNBUFFERED=1
ENV PORT=8080
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8080
# Using 'python' instead of 'python3' to match the slim image path
CMD ["python", "adk_app.py"]
