# Specifies the version of Python to be used for the container, alpine is a light weight version of python
FROM python:3.9-alpine3.13
# Name of the user that is in charge of maintaining the container, best practice to list this
LABEL maintainer="jegill"

# Recommend for Python in Docker Container, the output from Python will be printed directly to the console
ENV PYTHONUNBUFFERED 1

# Copy the requirements.txt and requirements.dev.txt from the local machine into the docker image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
# Copy over helper scripts
COPY ./scripts /scripts
# Copy the ./app directory from the local machine into the docker image
COPY ./app /app
# Change the current working directory to the /app directory inside the docker image
WORKDIR /app
# Expose port 8000 from inside the container to the local machine
EXPOSE 8000
# Create a build argument DEV that is false, this is overwritten if docker-compose is used which sets as true
ARG DEV=false

# Specifies a single run command with multiple commands, better than doing with multiple RUN lines as it prevents the
# addition of multiple docker image layers
# This command creates a new virutal enviornment to store dependencies, safe guards against any edge case conflicts
# between dependencies with the base image running
RUN python -m venv /py && \
    # Install and upgrade the python package manager pip
    /py/bin/pip install --upgrade pip && \
    # Installs the postgres client package so that psycopg2 can connect, install jpeg-dev package for Pillow
    apk add --update --no-cache postgresql-client jpeg-dev && \
    # Installs dependencies needed to setup psycopg2 and Pillow that can be removed after build complete \
    # linux-headers is specific to installing a uWSGI interface \
    # zlib and zlib dev are specific to installing Pillow
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev zlib zlib-dev linux-headers && \
    # Install required dependencies inside the virtual environment
    /py/bin/pip install -r /tmp/requirements.txt && \
    # Shell script that does an if statement checking DEV, if it is true install requirements.dev.txt
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    # Remove the /tmp directory to prevent there being extra dependencies on the image, keep it as lightweight as possible
    rm -rf /tmp && \
    # Removes the dependencies that are not needed after the build is completed and psycopg2 is setup \
    # Doing this will help keep the docker image more lightweight
    apk del .tmp-build-deps &&  \
    # Add new user inside the image, best practice to not use the root user, disable the ability to log on with a password,
    # prevent the creation of a home directory, and specify the name of the user
    adduser \
        --disabled-password \
        --no-create-home \
        django-user && \
    # Create the directories and all sub directories for storing media files
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    # Change the ownership of vol directory and all sub directories to django-user
    chown -R django-user:django-user /vol && \
    # Change the mode so that django-user can make changes to vol directory and all sub directories
    chmod -R 775 /vol && \
    # Change the scripts directory so that it is executable
    chmod -R +x /scripts

# Update the PATH variable inside the enviornment, avoids having to define the entire path when running commands
ENV PATH="/scripts:/py/bin:$PATH"

# Specifies the user that you are switching to from the root user
USER django-user
# Default command that is run for docker containers that are spawned from our images built by this dockerfile
# Overriden for developement enviormnent
CMD ["run.sh"]