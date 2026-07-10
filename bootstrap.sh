#!/bin/bash
set -e

# bootstrap.sh — one-shot setup for a fresh evaluation VM.
# Generates secrets, .env, /etc/hosts entry, and data dirs.
# Usage: ./bootstrap.sh           (auto-detects login)
#        ./bootstrap.sh wil       (uses "wil" as login)

LOGIN=${1:-$(id -un)}
DOMAIN="${LOGIN}.42.fr"
SECRETS_DIR="$(cd "$(dirname "$0")" && pwd)/secrets"
SRCS_DIR="$(cd "$(dirname "$0")" && pwd)/srcs"

echo "=== Inception bootstrap ==="
echo "Login:    ${LOGIN}"
echo "Domain:   ${DOMAIN}"
echo "Data dir: /home/${LOGIN}/data"
echo ""

# --- 1. secrets/ ---
echo "[1/4] Generating secrets..."
mkdir -p "${SECRETS_DIR}"

if [ ! -f "${SECRETS_DIR}/db_password.txt" ]; then
    openssl rand -base64 24 > "${SECRETS_DIR}/db_password.txt"
    echo "  created db_password.txt"
else
    echo "  db_password.txt already exists, skipping"
fi

if [ ! -f "${SECRETS_DIR}/db_root_password.txt" ]; then
    openssl rand -base64 24 > "${SECRETS_DIR}/db_root_password.txt"
    echo "  created db_root_password.txt"
else
    echo "  db_root_password.txt already exists, skipping"
fi

if [ ! -f "${SECRETS_DIR}/wp_admin_password.txt" ]; then
    openssl rand -base64 24 > "${SECRETS_DIR}/wp_admin_password.txt"
    echo "  created wp_admin_password.txt"
else
    echo "  wp_admin_password.txt already exists, skipping"
fi

if [ ! -f "${SECRETS_DIR}/wp_user_password.txt" ]; then
    openssl rand -base64 24 > "${SECRETS_DIR}/wp_user_password.txt"
    echo "  created wp_user_password.txt"
else
    echo "  wp_user_password.txt already exists, skipping"
fi

if [ ! -f "${SECRETS_DIR}/credentials.txt" ]; then
    cat > "${SECRETS_DIR}/credentials.txt" <<EOF
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
DOMAIN_NAME=${DOMAIN}
WP_TITLE=Inception
WP_ADMIN_USER=${LOGIN}
WP_ADMIN_EMAIL=admin@${DOMAIN}
WP_USR=author
WP_EMAIL=author@${DOMAIN}
EOF
    echo "  created credentials.txt"
else
    echo "  credentials.txt already exists, skipping"
fi

# --- 2. srcs/.env ---
echo "[2/4] Generating srcs/.env..."
if [ ! -f "${SRCS_DIR}/.env" ]; then
    cat > "${SRCS_DIR}/.env" <<EOF
# Database Configuration
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
DB_NAME=wordpress
DB_USER=wp_user
DB_HOST=mariadb

# Domain Configuration
DOMAIN_NAME=${DOMAIN}

# WordPress Configuration
WP_TITLE=Inception
WP_ADMIN_USER=${LOGIN}
WP_ADMIN_EMAIL=admin@${DOMAIN}
WP_USR=author
WP_EMAIL=author@${DOMAIN}

# FTP
FTP_USER=${LOGIN}
FTP_PASSWORD=$(openssl rand -base64 18 | tr -d '/+=' | head -c 20)
EOF
    echo "  created srcs/.env"
else
    echo "  srcs/.env already exists, updating DOMAIN_NAME..."
    sed -i "s/^DOMAIN_NAME=.*/DOMAIN_NAME=${DOMAIN}/" "${SRCS_DIR}/.env"
    sed -i "s/^WP_ADMIN_USER=.*/WP_ADMIN_USER=${LOGIN}/" "${SRCS_DIR}/.env"
    sed -i "s/^FTP_USER=.*/FTP_USER=${LOGIN}/" "${SRCS_DIR}/.env"
    echo "  updated existing .env with current login/domain"
fi

# --- 3. /etc/hosts ---
echo "[3/4] Configuring /etc/hosts..."
if grep -q "${DOMAIN}" /etc/hosts 2>/dev/null; then
    echo "  ${DOMAIN} already in /etc/hosts"
else
    echo "127.0.0.1 ${DOMAIN}" | sudo tee -a /etc/hosts > /dev/null
    echo "  added ${DOMAIN} -> 127.0.0.1"
fi

# --- 4. Data directories ---
echo "[4/4] Creating data directories..."
sudo mkdir -p "/home/${LOGIN}/data/wordpress"
sudo mkdir -p "/home/${LOGIN}/data/mariadb"
sudo chmod 777 "/home/${LOGIN}/data/wordpress"
sudo chmod 777 "/home/${LOGIN}/data/mariadb"
echo "  created /home/${LOGIN}/data/{wordpress,mariadb}"

echo ""
echo "=== Bootstrap complete ==="
echo "Run 'make' to build and start the project."