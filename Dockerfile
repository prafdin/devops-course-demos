FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

RUN pip install --no-cache-dir --upgrade pip build

COPY pyproject.toml README.md ./
COPY todo_app/ ./todo_app/

RUN python -m build --wheel --outdir dist

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:$PATH"

RUN useradd --create-home appuser

WORKDIR /home/appuser/app

COPY --from=builder /build/dist/*.whl ./

RUN chown -R appuser:appuser /home/appuser/app

USER appuser

RUN pip install --no-cache-dir --user *.whl && \
    rm *.whl

ENTRYPOINT ["todo"]

CMD ["--help"]
