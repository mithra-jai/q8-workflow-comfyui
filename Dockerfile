# Stage 1: Base image with common dependencies
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


# Change working directory to ComfyUI
WORKDIR /app

# Install ComfyUI dependencies
RUN pip3 install --upgrade --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --upgrade -r requirements.txt

# Install runpod
RUN pip3 install runpod requests

# Add custom nodes directly
RUN mkdir -p /q8-workflow-comfyui/custom_nodes && \
    git clone https://github.com/example/ComfyUI-GGUF.git /q8-workflow-comfyui/custom_nodes/ComfyUI-GGUF && \
    git clone https://github.com/example/ComfyUI-Manager.git /q8-workflow-comfyui/custom_nodes/ComfyUI-Manager && \
    git clone https://github.com/example/ComfyUI_bitsandbytes_NF4.git /q8-workflow-comfyui/custom_nodes/ComfyUI_bitsandbytes_NF4 && \
    git clone https://github.com/example/rgthree-comfy.git /q8-workflow-comfyui/custom_nodes/rgthree-comfy && \
    wget -O /q8-workflow-comfyui/custom_nodes/example_node.py https://raw.githubusercontent.com/example/example_node.py.example

# Support for models directory
RUN mkdir -p /q8-workflow-comfyui/models/checkpoints /q8-workflow-comfyui/models/clip /q8-workflow-comfyui/models/lora /q8-workflow-comfyui/models/vae /q8-workflow-comfyui/models/unet /q8-workflow-comfyui/models/text_encoders

# Add the start script and handler
ADD src/start.sh src/rp_handler.py  ./
RUN chmod +x /start.sh

# Stage 2: Download models
FROM base as downloader

# Change working directory to ComfyUI
WORKDIR /q8-workflow-comfyui

# Download all models
RUN wget -O models/checkpoints/flux1-dev-bnb-nf4-v2.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev-bnb-nf4-v2.safetensors && \
    wget -O models/clip/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors && \
    wget -O models/clip/clip_l.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors && \
    wget -O models/clip/t5-v1_1-xxl-encoder-Q6_K.gguf https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5-v1_1-xxl-encoder-Q6_K.gguf && \
    wget -O models/vae/ae.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors && \
    wget -O models/lora/Flux-1-dev-Turbo-Alpha.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/Flux-1-dev-Turbo-Alpha.safetensors && \
    wget -O models/text_encoders/t5xxl_fp8_e4m3fn.safetensors https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors && \
    wget -O models/unet/flux-hyp8-Q8_0.gguf https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux-hyp8-Q8_0.gguf && \
    wget -O models/unet/flux1-dev-fp8.safetensors https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev-fp8.safetensors

# Stage 3: Final image
FROM base as final

# Copy models and custom nodes from downloader to final image
COPY --from=downloader /q8-workflow-comfyui/models /q8-workflow-comfyui/models

# Start the container

CMD ["python", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

