FROM python:3.10 as builder

COPY ./calc /calc

RUN pip install --no-cache-dir -U pip wheel setuptools build && \
    cd /calc && \
    python3 -m build --wheel

FROM python:3.10 as runtime

LABEL original_maintainer="Sebastian Ramirez <tiangolo@gmail.com>"

COPY deployment/docker/requirements.txt /tmp/requirements.txt
COPY --from=builder /calc/calc-*.whl /tmp/calc.whl
RUN pip install --no-cache-dir -r /tmp/requirements.txt /tmp/calc.whl

COPY deployment/docker/start.sh /start.sh
RUN chmod +x /start.sh

COPY deployment/docker/start-kubernetes.sh /start-kubernetes.sh
RUN chmod +x /start-kubernetes.sh

COPY deployment/docker/gunicorn_conf.py /gunicorn_conf.py

COPY deployment/docker/start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh && mkdir -p /app

COPY deployment/docker/main.py /app/main.py
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]
