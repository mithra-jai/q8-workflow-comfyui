# Use an official lightweight Python image
FROM python:3.10-slim

# Install system dependencies if required
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /q8-workflow-comfyui

# Copy the already cloned/extracted repository files into the container
COPY . /q8-workflow-comfyui

# Install Python dependencies (requirements.txt is in the root of the project)
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r /q8-workflow-comfyui/requirements.txt

# Change to the directory containing the app
WORKDIR /q8-workflow-comfyui/app

# Expose the port your application runs on (adjust if necessary)
EXPOSE 8188

# Define the command to run the application
CMD ["python", "main.py"]
