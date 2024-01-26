# Use the official Python image as a base image
FROM python:3.12.1-alpine3.19

# Set metadata for an image
LABEL maintainer="sugamdahal.com.np"

# Set environment variable to avoid buffering issues
ENV PYTHONBUFFERED 1

# Copy requirements files and app code
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

# Set working directory
WORKDIR /app

# Expose port 8000
EXPOSE 8000

# Create a virtual environment
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt

# Conditional installation of development dependencies
ARG DEV=false
RUN if [ "$DEV" = "true" ]; then \
    /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser --disabled-password --no-create-home django-user

# Set the PATH to include the virtual environment
ENV PATH="/py/bin:$PATH"

# Switch to the django-user
USER django-user
