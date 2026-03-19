FROM python:3.11-slim
WORKDIR /app
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
COPY . .
RUN pip install --no-cache-dir .
ENV PORT 8080
EXPOSE 8080
# Use ENTRYPOINT + CMD to ensure main.py is the ONLY thing that runs
ENTRYPOINT ["python3"]
CMD ["main.py"]
