ARG PROMETHEUS_VERSION=2.52.0
FROM prom/prometheus:v${PROMETHEUS_VERSION}

USER root

# App config is fine to bake in
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Optional build-time substitution
ARG RENDER_SERVICE_NAME
RUN sed -i "s/RENDER_SERVICE_NAME/${RENDER_SERVICE_NAME}/g" /etc/prometheus/prometheus.yml || true

# Data dir for your Render disk
RUN mkdir -p /var/data/prometheus && chown -R nobody /var/data/prometheus

# Let 'nobody' read /etc/secrets/*
# (If usermod isn't present in the base image, this no-ops; see note below)
RUN usermod -a -G 1000 nobody || true

USER nobody

CMD [
  "--storage.tsdb.path=/var/data/prometheus",
  "--config.file=/var/data/prometheus/prometheus.yml",
  "--web.config.file=/var/data/prometheus/secrets/web.yml",
  "--web.console.libraries=/usr/share/prometheus/console_libraries",
  "--web.console.templates=/usr/share/prometheus/consoles"
]