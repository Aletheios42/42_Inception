NAME = inception

.PHONY: build up down clean fclean re

all: build up

build:
	docker-compose -f srcs/docker-compose.yml build

up:
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker system prune -af
	docker volume prune -f

fclean: down clean
	docker volume rm inception_wordpress_data || true

re: fclean build up
