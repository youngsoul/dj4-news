# Pull base image
FROM python:3.10.4-slim-bullseye

RUN apt-get update && apt-get -y upgrade && apt-get install --no-install-recommends -y \
  curl \
  zip \
  nano \
  build-essential \
  && rm -rf /var/lib/apt/lists/*


# Set environment variables
ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1


# Set working directory inside container
WORKDIR /code
RUN mkdir templates

# Install Dependencies
COPY ./requirements.in .
RUN pip install pip-tools
RUN pip-compile
RUN pip install -r requirements.txt

# copy local project code to container code
# first '.' is where the Dockerfile is, the second '.' is to the WORKDIR
COPY . .

RUN echo "run init_project.sh"

# run command to keep the container running
# override this command in docker-compose
CMD ["bash", "-c", "tail", "/dev/null"]
