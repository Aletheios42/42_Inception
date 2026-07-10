# User Documentation

## Services provided

| Service | Role | Accessible from outside? |
|---|---|---|
| NGINX | Reverse proxy / TLS termination | Yes — port 443 only |
| WordPress | CMS web application | No — internal only |
| MariaDB | Database | No — internal only |
| Redis *(bonus)* | Object cache for WordPress | No — internal only |
| Adminer *(bonus)* | Web UI to manage the database | Yes — port 8080 |
| FTP *(bonus)* | Access to the WordPress files | Yes — port 21 |
| cAdvisor *(bonus)* | Container resource monitoring | Yes — port 8081 |
| CV Server *(bonus)* | Static CV page (Node.js) | Via NGINX at /cv/ |

## Starting and stopping the project

```bash
# Start everything (builds images if needed, creates host data dirs)
make

# Stop containers without removing data
make down

# Stop and remove all Docker data and host data (destructive)
make fclean
```

## Accessing the website

1. Ensure `alepinto.42.fr` resolves to `127.0.0.1` in `/etc/hosts`.
2. Open `https://alepinto.42.fr` in a browser.
3. Accept the self-signed certificate warning.

**WordPress admin panel:** `https://alepinto.42.fr/wp-admin`

**Adminer (bonus):** `http://alepinto.42.fr:8080` — to browse the database, log in with server `mariadb`, user `wp_user`, database `wordpress`.

**cAdvisor (bonus):** `http://alepinto.42.fr:8081`

**FTP (bonus):** connect to `alepinto.42.fr` port `21` with user `alepinto` to browse and edit the WordPress site files.

**CV page (bonus):** `https://alepinto.42.fr/cv/`

### WordPress accounts

Two users are created on first launch (as required by the subject: one administrator and one regular user):

| Username | Role | Password |
|---|---|---|
| `alepinto` | Administrator | the value in `secrets/wp_admin_password.txt` |
| `author` | Author | the value in `secrets/wp_user_password.txt` |

To change these, edit `.env` (usernames) or the secrets (passwords) before the first `make`.

## Credentials

All sensitive credentials are stored as plain-text files under `secrets/` (never committed to git):

| File | Contains |
|---|---|
| `secrets/db_password.txt` | MariaDB password for the `wp_user` account |
| `secrets/db_root_password.txt` | MariaDB root password |
| `secrets/wp_admin_password.txt` | WordPress admin password |
| `secrets/wp_user_password.txt` | WordPress author password |

Inside running containers, secrets are available at `/run/secrets/<name>`.

The non-sensitive configuration (domain, usernames, DB name) lives in `srcs/.env`.

## Checking that services are running

```bash
# List running containers and their status
docker compose -f srcs/docker-compose.yml ps

# Follow all logs
make logs

# Check a specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb

# Quick health check
curl -sk https://alepinto.42.fr | grep -o '<title>[^<]*'
```