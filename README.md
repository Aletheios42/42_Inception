_This project has been created as part of the 42 curriculum by alepinto._

## Description

Inception is a system administration project that builds a small web infrastructure using Docker Compose. Each service runs in its own dedicated container built from Debian 12 (bookworm):

- **NGINX** — the sole entry point, serving HTTPS (TLSv1.2/1.3) on port 443 and forwarding PHP requests to WordPress via FastCGI.
- **WordPress + php-fpm** — the application layer, configured to connect to MariaDB.
- **MariaDB** — the database backend, isolated from the outside world.

Two named Docker volumes persist data on the host at `/home/<login>/data/`: one for the MariaDB database and one for the WordPress web files. A custom Docker bridge network connects all services.

### Request flow

```
Browser  --HTTPS/443-->  NGINX  --FastCGI/9000-->  WordPress (php-fpm)  --MySQL/3306-->  MariaDB
           (TLS 1.2/1.3)      (only 443 published)                    (internal network only)
```

Only NGINX is reachable from the host (port 443). WordPress (9000) and MariaDB (3306) are reachable only from within the `inception_net` bridge network.

### Bonus services

- **Redis** — object cache for WordPress (via the `redis-cache` plugin + `php-redis`), internal network only.
- **FTP** — vsftpd giving access to the WordPress website files, on port 21 (+ passive 21100-21110).
- **Adminer** — lightweight web UI to manage the MariaDB database, on port 8080.
- **cAdvisor** — container monitoring tool to visualize resource usage, on port 8081.
- **CV Server** — a simple static CV page served with Node.js, proxied through NGINX at `/cv/`.

### Design choices

| Topic | Choice | Rationale |
|---|---|---|
| **VMs vs Docker** | Docker | Containers share the host kernel — lighter, faster to start, easier to reproduce. VMs provide stronger isolation via a full OS but are heavier. |
| **Secrets vs Env Vars** | Secrets for passwords, `.env` for config | Docker secrets mount sensitive data as in-memory files (`/run/secrets/`), never exposed in `docker inspect` or logs. Env vars are convenient but visible to any process in the container. |
| **Docker Network vs Host Network** | Custom bridge (`inception_net`) | A bridge network isolates containers from the host and from each other's ports. `network: host` removes isolation and is forbidden by this subject. |
| **Docker Volumes vs Bind Mounts** | Named volumes with local driver | The subject requires named volumes whose data lives in `/home/login/data`, and forbids bind mounts. A named volume with `local` driver + `o: bind` stays Docker-managed while pinning data to the host path. |
| **Base image** | `debian:bookworm` | The subject forbids `latest` and requires the penultimate stable release. With Debian 13 (trixie) as the current stable, Debian 12 (bookworm) is the penultimate one. |

## Instructions

### Prerequisites

- Docker and Docker Compose installed.
- `sudo` access (to create `/home/<login>/data/`).
- Add `alepinto.42.fr` to `/etc/hosts` pointing to `127.0.0.1`.

```bash
echo "127.0.0.1 alepinto.42.fr" | sudo tee -a /etc/hosts
```

### Build and run

```bash
make        # creates data dirs, builds images, starts containers
```

### Other Makefile targets

```bash
make up     # start already-built containers
make down   # stop containers
make build  # rebuild images without starting
make logs   # follow logs from all services
make clean  # stop + prune unused Docker data
make fclean # full reset — volumes, images, host data
make re     # fclean + all
```

### Access

- **Website:** `https://alepinto.42.fr` (accept the self-signed certificate warning).
- **WordPress admin:** `https://alepinto.42.fr/wp-admin`
- **Adminer (bonus):** `http://alepinto.42.fr:8080` — log in with server `mariadb`, user `wp_user`, database `wordpress`.
- **cAdvisor (bonus):** `http://alepinto.42.fr:8081`
- **FTP (bonus):** `ftp://alepinto.42.fr:21` — user `alepinto` (password in `srcs/.env` FTP_PASSWORD).
- **CV page (bonus):** `https://alepinto.42.fr/cv/`

## Resources

### References

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [PID 1 and Docker best practices](https://cloud.google.com/architecture/best-practices-for-building-containers#signal-handling)
- [Docker secrets](https://docs.docker.com/engine/swarm/secrets/)