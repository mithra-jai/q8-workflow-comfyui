# Use an official lightweight Python image
FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository from GitHub
RUN git clone https://github.com/mithra-jai/q8-workflow-comfyui.git .

# Set the working directory to the app directory where the code is located
WORKDIR /q8-workflow-comfyui/app

# Install Python dependencies from the requirements file
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r /q8-workflow-comfyui/requirements.txt

# Expose the port your application runs on (adjust if necessary)
EXPOSE 8188

# Define the command to run the application
CMD ["python", "main.py"]
