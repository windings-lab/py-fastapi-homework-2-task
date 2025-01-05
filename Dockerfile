FROM python:3.10

# Selecting a working directory
WORKDIR /usr/src/fastapi

# Setting environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=off
ENV ALEMBIC_CONFIG = /usr/src/alembic/alembic.ini

# Installing dependencies
RUN apt update && apt install -y \
    gcc \
    libpq-dev \
    netcat-openbsd \
    postgresql-client \
    && apt clean

# Copy dependency files
COPY ./poetry.lock /usr/src/poetry/poetry.lock
COPY ./pyproject.toml /usr/src/poetry/pyproject.toml
COPY ./alembic.ini /usr/src/alembic/alembic.ini

# Install Poetry
RUN python -m pip install --upgrade pip && \
    pip install poetry

# Configure Poetry to avoid creating a virtual environment
RUN poetry config virtualenvs.create false

# Install dependencies with Poetry
RUN poetry lock --no-update --directory /usr/src/poetry
RUN poetry install --no-root --only main --directory /usr/src/poetry

# Copy the source code
COPY ./src .

# Copy commands
COPY ./commands /commands

# Add execute bit to commands files
RUN chmod +x /commands/*.sh
