#!/usr/bin/env bash
#
# vm-setup.sh — One-shot setup for a fresh Lubuntu/Ubuntu VM.
# Installs Docker, Docker Compose, make, openssl, openssh-server,
# configures DNS, and prepares the user for docker group access.
#
# Must be run with sudo or as root:
#   sudo ./vm-setup.sh
#
# Idempotent: safe to re-run.

set -e

# --- Must be root ---
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: run with sudo: sudo ./vm-setup.sh"
    exit 1
fi

# Discover the real user (not root) for docker group
REAL_USER="${SUDO_USER:-$USER}"
LOGIN="${REAL_USER}"

echo "=========================================="
echo "  Inception VM Setup"
echo "  User:  ${LOGIN}"
echo "  OS:    $(cat /etc/os-release | grep ^PRETTY_NAME | cut -d= -f2)"
echo "=========================================="
echo ""

# --- 1. System packages ---
echo "[1/6] Installing system packages..."
apt-get update -qq
apt-get install -y -qq \
    curl \
    git \
    make \
    openssl \
    openssh-server \
    ca-certificates \
    > /dev/null
echo "  done"

# --- 2. SSH server ---
echo "[2/6] Enabling SSH..."
systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd 2>/dev/null || true
echo "  ssh running on port 22"

# --- 3. Docker ---
echo "[3/6] Installing Docker..."
if command -v docker >/dev/null 2>&1; then
    echo "  docker already installed ($(docker --version | cut -d' ' -f3))"
else
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sh /tmp/get-docker.sh > /dev/null 2>&1
    rm /tmp/get-docker.sh
    echo "  docker installed ($(docker --version | cut -d' ' -f3))"
fi

# --- 4. Docker Compose plugin ---
echo "[4/6] Checking Docker Compose..."
if docker compose version >/dev/null 2>&1; then
    echo "  docker compose $(docker compose version --short)"
else
    apt-get install -y -qq docker-compose-plugin > /dev/null 2>&1 || true
    if docker compose version >/dev/null 2>&1; then
        echo "  docker compose installed"
    else
        echo "  WARNING: docker compose not available — install docker-compose-plugin manually"
    fi
fi

# --- 5. Docker group ---
echo "[5/6] Adding ${LOGIN} to docker group..."
if id -nG "${LOGIN}" | grep -qw docker; then
    echo "  ${LOGIN} already in docker group"
else
    usermod -aG docker "${LOGIN}"
    echo "  ${LOGIN} added to docker group"
    echo "  NOTE: log out and back in for group change to take effect"
fi

systemctl enable --now docker > /dev/null 2>&1 || true

# --- 6. DNS configuration for dnsmasq container ---
echo "[6/6] Configuring DNS..."
# Stop systemd-resolved if it occupies port 53
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    systemctl disable --now systemd-resolved 2>/dev/null || true
    rm -f /etc/resolv.conf
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "  systemd-resolved disabled, DNS -> 127.0.0.1 (dnsmasq container)"
elif [ -f /etc/resolv.conf ] && ! grep -q "127.0.0.1" /etc/resolv.conf 2>/dev/null; then
    cp /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
    echo "  DNS -> 127.0.0.1 (dnsmasq container)"
else
    echo "  DNS already configured"
fi

# --- Summary ---
echo ""
echo "=========================================="
echo "  VM Setup complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Log out and back in (for docker group):  exit"
echo "  2. Get the project onto this VM:"
echo "     git clone <repo-url>"
echo "     cd inception"
echo "  3. Run:  ./bootstrap.sh && make"
echo ""
echo "SSH access from your host:"
IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -n "${IP}" ]; then
    echo "  ssh ${LOGIN}@${IP}"
fi
echo ""
echo "View services after 'make':"
echo "  https://${LOGIN}.42.fr/services"
echo "=========================================="