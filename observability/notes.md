# Observability Notes

## Prometheus & Grafana (Optional Enhancement)

The assignment mentions Prometheus and Grafana in the architecture diagram requirement.
Here are notes on how to set them up if needed:

### Jenkins Prometheus Metrics

1. Install the **Prometheus Metrics** plugin in Jenkins
2. Metrics will be exposed at `http://<JENKINS_URL>/prometheus/`

### Prometheus Setup

```yaml
# docker-compose.yml for Prometheus + Grafana
version: "3.8"
services:
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    restart: unless-stopped
```

### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'jenkins'
    metrics_path: '/prometheus/'
    static_configs:
      - targets: ['<JENKINS_IP>:8080']
```

### Grafana Dashboard

Import the Jenkins dashboard from Grafana.com:
- Dashboard ID: **9964** (Jenkins Performance and Health Overview)
