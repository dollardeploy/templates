# msgboard has no published image, so install the pinned upstream revision with pip.
FROM python:3.12-slim

ARG MSGBOARD_REF=f4a33aeae6965e7826d6c4b1410d05f312dfb5b2
RUN pip install --no-cache-dir "msgboard @ https://github.com/huggingface/msgboard/archive/${MSGBOARD_REF}.tar.gz"

# Run as an unprivileged user; the data dir exists in the image so the named volume inherits its owner.
RUN useradd -m -u 1000 user && mkdir -p /data && chown user:user /data && chmod 700 /data
WORKDIR /app
COPY entrypoint.py ./
USER user

ENV PYTHONUNBUFFERED=1 MSGBOARD_DATA_DIR=/data PORT=7860
EXPOSE 7860
# exec form: SIGTERM reaches Python, which closes the board cleanly
CMD ["python", "/app/entrypoint.py"]
