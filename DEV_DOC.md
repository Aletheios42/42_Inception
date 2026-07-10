# Developer Documentation

## Prerequisites

- Docker Engine 24+
- Docker Compose plugin (`docker compose`, not `docker-compose`)
- `sudo` access on the host
- `make`

## Environment setup from scratch

### 1. Clone the repository

```bash
git clone <repo-url>
cd inception
```

### 2. Create secrets

The `secrets/` directory is git-ignored. Create the four files with strong passwords:

```bash
mkdir -p secrets
echo 'YourDbPassword!'     > secrets/db_password.txt
echo 'YourRootPassword!'   > secrets/db_root_password.txt
echo 'YourAdminPassword!'  > secrets/wp_admin_password.txt
echo 'YourUserPassword!'   > secrets/wp_user_password.txt
```

### 3. Configure `.env`

`srcs/.env` is also git-ignored. Create it with:

```bash
cat > srcs/.env <<EOF
DOMAIN_NAME=alepinto.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
DB_NAME=wordpress
DB_USER=wp_user
DB_HOST=mariadb
WP_TITLE=Mi sitio WordPress
WP_ADMIN_USER=alepinto
WP_ADMIN_EMAIL=admin@example.com
WP_USR=author
WP_EMAIL=author@example.com
FTP_USER=alepinto
FTP_PASSWORD=changeme
EOF
```

### 4. Add the domain to `/etc/hosts`

```bash
echo "127.0.0.1 alepinto.42.fr" | sudo tee -a /etc/hosts
```

## Building and launching

```bash
make        # mkdir data dirs + docker compose up -d --build
make build  # rebuild images only
make up     # start pre-built containers
make down   # stop containers (data is preserved)
make re     # full rebuild from scratch (destroys data)
```

## Useful Docker Compose commands

```bash
# Shell into a running container
docker exec -it nginx bash
docker exec -it wordpress bash
docker exec -it mariadb bash

# Check MariaDB
docker exec -it mariadb mysql -u root -p

# Run WP-CLI commands
docker exec -it wordpress wp --allow-root user list

# Inspect a named volume
docker volume ls
docker volume inspect <volume_name>

# Remove all project containers, networks, volumes
docker compose -f srcs/docker-compose.yml down -v
```

## Data persistence

| Named volume | Host path | Container path |
|---|---|---|
| `inception_net-wp-files` (or `wp-files`) | `/home/<login>/data/wordpress` | `/var/www/html` |
| `inception_net-wp-database` (or `wp-database`) | `/home/<login>/data/mariadb` | `/var/lib/mysql` |

Both volumes use the `local` driver with `type: none, o: bind`, which pins the Docker-managed volume to the given host directory. The host directories are created by `make` before the first `docker compose up`.

Data survives `make down`. Only `make fclean` removes host data.

> **Portability note.** The volume host paths are derived from the user running `make`: the `Makefile` sets `LOGIN ?= $(shell id -un)` and exports `DATA_PATH=/home/$(LOGIN)/data`, which `docker-compose.yml` substitutes into the `device:` of each volume.

## Project layout

```
.
├── Makefile                              # orchestration
├── README.md                             # project description
├── USER_DOC.md                           # user documentation
├── DEV_DOC.md                           # this file
├── secrets/                              # git-ignored, holds plaintext secrets
│   ├── credentials.txt
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env                              # git-ignored, non-sensitive config
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/nginx.conf.template  # envsubst processes DOMAIN_NAME
        │   └── tools/entrypoint.sh       # generates TLS cert + processes template
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/my.cnf
        │   └── tools/init-db.sh          # one-time DB + user bootstrap
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── .dockerignore
        │   ├── conf/www.conf             # php-fpm pool, listens on 0.0.0.0:9000
        │   └── tools/setup-wp.sh         # downloads WP, installs, creates users, wires Redis
        └── bonus/
            ├── redis/
            │   ├── Dockerfile
            │   └── conf/redis.conf       # cache config, foreground redis-server
            ├── adminer/
            │   └── Dockerfile            # downloads Adminer, serves with php -S :8080
            ├── ftp_server/
            │   ├── Dockerfile
            │   ├── conf/vsftpd.conf
            │   └── tools/entrypoint.sh   # creates ftp user, chowns wp volume
            ├── cadvisor/
            │   └── Dockerfile            # downloads cadvisor binary
            └── cv_server/
                ├── Dockerfile
                ├── package.json
                ├── server.js             # Node.js HTTP server
                └── public/index.html
```

## How each container starts

**MariaDB** — `init-db.sh` first recreates `/run/mysqld` (needed because `/run` is a fresh tmpfs each start). It bootstraps only if the application database is absent. When bootstrapping, it starts a temporary `--skip-networking` server, creates the database and users, shuts it down cleanly, then exec-s `mysqld`. The custom config (`my.cnf`) lives in `mariadb.conf.d/99-inception.cnf` so its `bind-address = 0.0.0.0` overrides the default.

**WordPress** — `setup-wp.sh` polls MariaDB until it responds, then uses WP-CLI to download WordPress, create `wp-config.php` (via `wp config create`), run the installer, and create the author user. Redis cache is configured via `wp config set` and the `redis-cache` plugin. Idempotent: skipped if `wp core is-installed` returns true.

**NGINX** — `entrypoint.sh` generates a self-signed TLS certificate (once) and processes the nginx config template with `envsubst` before exec-ing `nginx -g 'daemon off;'`.

**Redis (bonus)** — no script: `redis-server /etc/redis/redis.conf` runs in the foreground as PID 1. Only on the internal network, no published ports.

**Adminer (bonus)** — no script: the image downloads Adminer at build time and serves it with PHP's built-in server in the foreground.

**FTP (bonus)** — `entrypoint.sh` creates the FTP user (password from `.env`), waits for WordPress to finish downloading, then chowns the shared volume before exec-ing `vsftpd` in the foreground.

**cAdvisor (bonus)** — no script: the binary runs directly as PID 1.

**CV Server (bonus)** — no script: `node server.js` runs in the foreground as PID 1. Proxied through NGINX at `/cv/`.

### Why `exec "$@"` (PID 1 and signals)

Every entrypoint ends with `exec "$@"`, which replaces the shell process with the real service (the `CMD`) so it becomes PID 1 of the container. This matters because:

- PID 1 receives `SIGTERM` from `docker compose down` / `docker stop` directly, so the service shuts down cleanly instead of being force-killed after the 10s timeout.
- Without `exec`, the shell would stay PID 1 and the service would be a child that never sees the stop signal.

This is also why the services run in the foreground (`nginx -g 'daemon off;'`, `php-fpm -F`, `mysqld`): a backgrounded daemon would let the container exit immediately. No hacky "keep-alive" tricks are used anywhere.