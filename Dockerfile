# Specify a different Prometheus version as needed
ARG PROMETHEUS_VERSION=2.52.0

# Use the official Prometheus base image
FROM prom/prometheus:v${PROMETHEUS_VERSION}

# Switch to root so we can place files, edit them, and set ownership/permissions
#USER root

# Copy configs into the image
# (Use COPY over ADD; COPY is clearer for local files)
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY web.yml        /etc/prometheus/web.yml

# Optional: substitute RENDER_SERVICE_NAME placeholder at build time
# Note: If you prefer runtime substitution (recommended on Render), see the note below.
ARG RENDER_SERVICE_NAME
RUN sed -i "s/RENDER_SERVICE_NAME/${RENDER_SERVICE_NAME}/g" /etc/prometheus/prometheus.yml || true

# Lock down web.yml and make both configs readable by the Prometheus runtime user
# Prometheus runs as 'nobody' in the official image.
#RUN chown -R nobody /etc/prometheus \
# && chmod 600 /etc/prometheus/web.yml
#
## Ensure the TSDB path exists on Render's persistent disk and is writable
#RUN mkdir -p /var/data/prometheus \
# && chown -R nobody /var/data/prometheus
#
## Drop back to the image's non-root user
#USER nobody

# Provide flags to the base image's entrypoint (/bin/prometheus)
CMD [
  "--storage.tsdb.path=/var/data/prometheus",
  "--config.file=/etc/prometheus/prometheus.yml",
  "--web.config.file=/etc/prometheus/web.yml",
  "--web.console.libraries=/usr/share/prometheus/console_libraries",
  "--web.console.templates=/usr/share/prometheus/consoles"
]

