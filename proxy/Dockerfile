# Dockerfile for running the nginx container

# Base image from nginx, this version doesn't run in the root user account, so it is more secure
FROM nginxinc/nginx-unprivileged:1-alpine
# Maintainer for the image, best practice to list
LABEL maintainer="joseph.gill@incling.com"
# Copy the template file inside the docker container to the listed location
COPY ./default.conf.tpl /etc/nginx/default.conf.tpl
# Copy the uWSGI params file inside the docker container to the listed location
COPY ./uwsgi_params /etc/nginx/uwsgi_params
# Copy the run script file inside the docker container to the listed location
COPY ./run.sh /run.sh
# Default values for container's enviorment variables, used if not overwritten
ENV LISTEN_PORT=8000
# Hostname where the uwsgi app is running
ENV APP_HOST=app
# Port where the uwsgi app is running
ENV APP_PORT=9000
# Change to the root user, need to change to be able to setup the image and run commands below
USER root
# Create the directory where we are storing the static files
RUN mkdir -p /vol/static && \
    # Setup permission so that you are able to read the contents of the static files
    chmod 755 /vol/static && \
    # Create the file so that you can set permissions on the file so it can be edited during the run.sh script
    touch /etc/nginx/conf.d/default.conf && \
    # Setup permission so the nginx user is the owner of the file created above
    chown nginx:nginx /etc/nginx/conf.d/default.conf && \
    # Add execute permission to the run.sh so that the docker container can run the scripts
    chmod +x /run.sh
# Setup the default volume for the docker container
VOLUME /vol/static
# Switch back to the nginx user so that you aren't root user, whichever is the last user switched when building the image
# is the user that is used when running the applicate
USER nginx
# Run the script
CMD ["/run.sh"]