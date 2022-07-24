# @ suppresses the normal 'echo' of the command that is executed.
# - means ignore the exit status of the command that is executed (normally, a non-zero exit status would stop that part of the build).
# + means 'execute this command under make -n' (or 'make -t' or 'make -q') when commands are not normally executed.

# Containers ids
db-id=$(shell docker ps -a -q -f "name=pg14-news-db"  | head -n 1)
web-id=$(shell docker ps -a -q -f "name=news-web" | head -n 1)

show-ids:
	@echo "web container id: " $(web-id)
	@echo "db container id:  " $(db-id)

# Build docker containers
build: build-web build-db

clean-build:
	@docker-compose -f docker-compose.yml build --no-cache


build-web:
	@docker-compose -f docker-compose.yml build django-web

build-db:
	@docker-compose -f docker-compose.yml build django-db

# Run docker containers
run:
	@docker-compose -f docker-compose.yml up

run-back:
	@docker-compose -f docker-compose.yml up -d

runbuild-web:
	@docker-compose -f docker-compose.yml up --build django-web

run-web:
	@docker-compose -f docker-compose.yml up django-web

run-db:
	@docker-compose -f docker-compose.yml up django-db

# restart containers with a stop then run
restart: stop run

restart-web: stop-web run-web

# Stop docker containers, but not remove them nor the volumes
stop:
	@docker-compose stop

stop-db:
	-@docker stop $(db-id)

stop-web:
	-@docker stop $(web-id)

# Stop docker containers, remove them AND the named data volumes
down:
	@docker-compose down -v


# Remove docker containers
rm-all: rm-web rm-db
rm-db:
	-@docker rm $(db-id)
rm-web:
	-@docker rm $(web-id)


# Go to container bash shell
shell-web:
	@docker exec -it $(web-id) bash

shell-db:
	@docker exec -it $(db-id) bash

run-tests:
	@docker-compose exec django-web python manage.py test

# make migrations appname=posts
migrations:
	@docker-compose exec django-web python manage.py makemigrations $(appname)

migrate:
	@docker-compose exec django-web python manage.py migrate

collectstatic:
	@docker-compose exec django-web python manage.py collectstatic


logs:
	@docker-compose logs

# Django commands
# make cmd=migrate manage
# make cmd="startapp accounts" manage
manage:
	@docker exec -t $(web-id) python manage.py $(cmd)

# make  startapp app="pages"
startapp:
	@docker exec -t $(web-id) python manage.py startapp $(app)

volumes:
	@docker volume ls


#make volname=books_postgres_data remove-volume
remove-volume:
	@docker volume rm $(volname)

superuser:
	-docker exec -it $(web-id) python manage.py createsuperuser

deploy-checklist:
	@docker exec -t $(web-id) python manage.py check --deploy

generate-secret-key:
	@docker exec -t $(web-id) python -c 'import secrets; print(secrets.token_urlsafe(38))'

# Heroku command
heroku-login:
	@heroku login

heroku-whoami:
	@heroku login

heroku-create:
	@heroku create

# make heroku-stop-app appname=gentle-earth-75811
heroku-stop-app:
	@heroku ps:scale web=0 --app $(appname)

# scale heroku to free tier dyno
heroku-web-1:
	@heroku ps:scale web=1 --app $(appname)

# make heroku-set-container appname=gentle-earth-75811
heroku-set-container:
	@heroku stack:set container -a $(appname)

# make heroku-create-postgres appname=gentle-earth-75811
heroku-create-postgres:
	@heroku addons:create heroku-postgresql:hobby-dev -a $(appname)

heroku-django-secret-key:
	@heroku config:set DJANGO_SECRET_KEY=$(shell python -c 'import secrets; print(secrets.token_urlsafe(38))')  -a $(heroku-app-name)


# make heroku-git-remote appname=gentle-earth-75811
heroku-git-remote:
	@heroku git:remote -a $(appname)

heroku-push-master:
	-git remote -v
	-git push heroku master

# make heroku-open appname=gentle-earth-75811
heroku-open:
	@heroku open -a $(appname)

# Django commands
# make cmd=migrate heroku-manage
# make cmd=createsuperuser heroku-manage
heroku-manage:
	@heroku run python manage.py $(cmd)
