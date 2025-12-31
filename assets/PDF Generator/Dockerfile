# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set locale for Arabic filename support
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies for PDF handling and fonts
RUN apt-get update && apt-get install -y \
    libmupdf-dev \
    mupdf-tools \
    gcc \
    libffi-dev \
    locales \
    fonts-dejavu-core \
    fonts-freefont-ttf \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p uploads generated_pdfs data

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PORT=8080

# Expose port
EXPOSE 8080

# Run the application with proper error output
CMD ["sh", "-c", "python -c 'from app.main import app; print(\"App imported successfully\")' && uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
