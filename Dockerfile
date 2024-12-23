# Use an official lightweight Python image
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory for the repository
WORKDIR /q8-workflow-comfyui

# Clone the repository (ensures the right directory structure)
RUN git clone https://github.com/mithra-jai/q8-workflow-comfyui.git .

# Check that the clone succeeded by listing files
RUN ls -l /q8-workflow-comfyui

# Set the working directory to where the app is located
WORKDIR /q8-workflow-comfyui/app

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Expose the port your application runs on
EXPOSE 8188

# Define the command to run the application
CMD ["python", "main.py"]
