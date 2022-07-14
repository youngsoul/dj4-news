# Simple Sample Django4 Docker Project Starter

The goal of this repo is to create an Django4.x/Postgres docker environment without you having to create a local python virtual environment.  The virtual environment will be created in the image and the running container from the image.  

This repo assumes you have Docker installed and can issue docker and docker-compose commands from a terminal window.

After cloning the repo, run the `init_project.sh` script.  This will build the image, start the container and execute the `django-admin startproject`, in the running container.

To add new Python dependencies, update the requirements.in file, and rebuild the image.

### pip-tools
This docker image uses `pip-tools` to manage dependencies.  By placing the dependent module name with an optional version in the `requirements.in` file, the module and its dependencies will be installed into the Python virtual environment of the container.


## Setup

* clone this repo and in terminal window run:

```shell
git clone https://github.com/youngsoul/sample-django4-docker-project-starter.git <projectdirname>
```

* review `init_project.sh`

Either run the script or execute each of the commands to get a base Django project.

Note that this will NOT run an initial migration because we want to create a customer User model BEFORE we run the initial migration.

```shell
chmod +x init_project.#!/bin/sh
./init_project.sh
```

## PyCharm

You can now create a PyCharm project and set the Python Interpreter to the docker-compose.yml files selecting 'django-web' as the service

This will keep you from having to create a local venv just to install Django and call startproject.

## Settings.py

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'djangodb',
        'USER': 'postgres',
        'PASSWORD': 'postgres',
        'HOST': 'django-db', # set in docker-compose.yml
        'PORT': 5432
    }
}

```

When the script finishes, the docker containers for the Django WebServer and Postgres DB are running.

You can open a browser and go to:

http://localhost:8080

and you should see the familiar Django start page.


## Custom User model

You almost always want to create a customer user model, BEFORE your initial migration.

* Create a CustomUser model
* Update django_project/settings.py
* Customize UserCreationForm and UserChangeForm
* Add the custom user model to admin.py

```shell
docker-compose exec django4-web python manage.py startapp accounts

or

make cmd="startapp accounts" manage
```

```python
# accounts/models.py
from django.db import models
from django.contrib.auth.models import AbstractUser
# Create your models here.

class CustomUser(AbstractUser):
    pass
```

* settings.py

```python
# django_project/settings.py
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Local
    "accounts"
]

# at the bottom of the file
AUTH_USER_MODEL = "accounts.CustomUser"
```

* Make migrations

```shell
docker-compose exec django-web python manage.py makemigrations accounts

or

make migrations

or

make cmd="makemigrations accounts" manage

```

* Run migrations

```shell
docker-compose exec django-web python manage.py migrate

or

make migrate

or

make cmd=migrate manage

```

* Create Superuser

```shell
make superuser
```
