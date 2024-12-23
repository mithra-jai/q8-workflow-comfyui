# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /q8-workflow-comfyui/app

# Install system dependencies if required (add any system libraries needed for your workflow)
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository from GitHub into the working directory
RUN git clone https://github.com/mithra-jai/q8-workflow-comfyui.git /q8-workflow-comfyui

# Change to the directory containing the app
WORKDIR /q8-workflow-comfyui/app

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Expose the port your application runs on (adjust if necessary)
EXPOSE 8188

# Define the command to run the application (replace with your script/command)
CMD ["python", "main.py"]
