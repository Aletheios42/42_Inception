LOGIN		?= $(shell id -un)
DATA_PATH	= /home/$(LOGIN)/data
COMPOSE		= docker compose -f srcs/docker-compose.yml

export DATA_PATH

.PHONY: all build up down logs status vm-setup clean fclean re

all: $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	$(COMPOSE) up -d --build
	@$(MAKE) --no-print-directory status

$(DATA_PATH)/wordpress:
	sudo mkdir -p $(DATA_PATH)/wordpress
	sudo chmod 777 $(DATA_PATH)/wordpress

$(DATA_PATH)/mariadb:
	sudo mkdir -p $(DATA_PATH)/mariadb
	sudo chmod 777 $(DATA_PATH)/mariadb

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

status:
	@echo ""
	@echo "================================================"
	@echo "  INCEPTION - Services Dashboard"
	@echo "  Domain: $(LOGIN).42.fr"
	@echo "================================================"
	@echo ""
	@printf "  \033[1mWordPress\033[0m        https://$(LOGIN).42.fr\n"
	@printf "  \033[1mWP Admin\033[0m         https://$(LOGIN).42.fr/wp-admin\n"
	@printf "  \033[1mServices\033[0m         https://$(LOGIN).42.fr/services\n"
	@printf "  \033[1mAdminer\033[0m          http://$(LOGIN).42.fr:9080\n"
	@printf "  \033[1mcAdvisor\033[0m         http://$(LOGIN).42.fr:8081\n"
	@printf "  \033[1mCV Page\033[0m          https://$(LOGIN).42.fr/cv/\n"
	@printf "  \033[1mFTP\033[0m              ftp://$(LOGIN).42.fr:21\n"
	@printf "  \033[1mDNS\033[0m              127.0.0.1:53 (dnsmasq)\n"
	@echo ""
	@printf "  \033[90mInternal only:\033[0m\n"
	@printf "  \033[90m  MariaDB\033[0m         mariadb:3306\n"
	@printf "  \033[90m  Redis\033[0m           redis:6379\n"
	@echo ""
	@printf "  \033[90mLogs: make logs | Stop: make down\033[0m\n"
	@echo "================================================"
	@echo ""

vm-setup:
	@echo "Running vm-setup.sh (requires sudo)..."
	sudo ./vm-setup.sh
	@echo ""
	@echo "Next: ./bootstrap.sh && make"
	@echo "If docker group was just added, log out and back in first."

clean: down
	docker system prune -f

fclean: clean
	docker volume rm -f $$(docker volume ls -q) 2>/dev/null || true
	sudo rm -rf $(DATA_PATH)

re: fclean all