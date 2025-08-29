# Docker Registry Setup (Standalone, with Docker Compose)

This guide explains how to run a Docker registry using Docker Compose and configure K3s to allow insecure (HTTP) registry access for large image uploads.

---

## 1. Prerequisites
- Docker and Docker Compose installed
- (Optional) Self-signed certificates if you want HTTPS (see `generate-certs.sh`)

---

## 2. Setup Registry with Docker Compose

1. **Clone or copy the files to your server:**
   - `docker-compose.yml`
   - `config.yml`
   - `certs/` (if using HTTPS)

2. **Create the data directory:**
   ```bash
   sudo mkdir -p /opt/docker-registry-data
   sudo chown $USER:$USER /opt/docker-registry-data
   ```

3. **Start the registry:**
   ```bash
   docker compose up -d
   ```
   - By default, this runs the registry on port 5000 (HTTP)
   - For HTTPS, update `docker-compose.yml` and `config.yml` to use port 443 and provide certs

4. **Test the registry:**
   ```bash
   curl http://localhost:5000/v2/
   # Should return {}
   ```

---

## 3. Configure Docker to Allow Insecure Registry

Add the following to `/etc/docker/daemon.json`:
```json
{
  "insecure-registries": ["localhost:5000", "yourdomainname.com:5000"]
}
```
Then restart Docker:
```bash
sudo systemctl restart docker
```

---

## 4. Configure K3s to Allow Insecure Registry (optional)

Add the following to `/etc/rancher/k3s/registries.yaml`:
```yaml
mirrors:
  "yourdomainname.com:5000":
    endpoint:
      - "http://yourdomainname.com:5000"
```
Then restart K3s:
```bash
sudo systemctl restart k3s
```

---

## 5. Tag and Push Images

Tag your image for the registry:
```bash
docker tag <local-image> yourdomainname.com:5000/<image-name>:<tag>
```
Push the image:
```bash
docker push yourdomainname.com:5000/<image-name>:<tag>
```

---

## 6. Troubleshooting
- If you see `http: server gave HTTP response to HTTPS client`, it means the registry is running on HTTP but the client expects HTTPS. Make sure the registry and all configs use HTTP if you don't use TLS.
- For large uploads, ensure timeouts are set high in `config.yml` and Docker Compose.
- If you change ports, update all references in configs and `/etc/hosts` as needed.

---

## 7. References
- [Docker Registry Documentation](https://docs.docker.com/registry/)
- [K3s Registry Configuration](https://rancher.com/docs/k3s/latest/en/networking/#private-registries)
