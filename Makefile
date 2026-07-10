LOGIN		?= $(shell id -un)
DATA_PATH	= /home/$(LOGIN)/data
COMPOSE		= docker compose -f srcs/docker-compose.yml

export DATA_PATH

.PHONY: all build up down logs clean fclean re

all: $(DATA_PATH)/wordpress $(DATA_PATH)/mariadb
	$(COMPOSE) up -d --build

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

clean: down
	docker system prune -f

fclean: clean
	docker volume rm -f $$(docker volume ls -q) 2>/dev/null || true
	sudo rm -rf $(DATA_PATH)

re: fclean all