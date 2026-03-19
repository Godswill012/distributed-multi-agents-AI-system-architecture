FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

# Copy the requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application (agent.py, adk_app.py)
COPY . .

EXPOSE 8080

# Start the server using the adk_app script
CMD ["python", "adk_app.py"]
