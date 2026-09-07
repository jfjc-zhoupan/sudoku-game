# Base Image - tells Docker all subsequent instructions start from this foundation
FROM python:3.14-slim

# Set Working Directory - tells Docker where all subsequent commands should be executed
WORKDIR /app

# Copy Requirements File - Copy from the host to the container's current working directory
COPY requirements.txt .

# Install Dependencies - install all the Python packages listed in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy Application Code - copy all files from the host into the container's WORKDIR
COPY . .

# Expose Port - only declares a port, tell that this container will listen on port 5000 when running
EXPOSE 5000

# Set Environment Variable - tells Flask framework which file is the main application
ENV FLASK_APP=app.py

# Define Entrypoint - default startup command
CMD ["python", "app.py"]

