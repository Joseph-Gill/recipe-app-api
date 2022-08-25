# Sets this as a shell script file
#!/bin/sh

#If any part of the next steps fail, fail the entire script
set -e

# Wait for the database to be available
python manage.py wait_for_db
# Collect all of the static files used for the project and place them in the configured directory
python manage.py collectstatic --noinput
# Run any migrations when app is started
python manage.py migrate
# Run the uWSGI service on port 9000, set 4 wsgi workers, set uWSGI daemon as master thread, enable multithreading
# and specify service the entry point is app/wsgi.py
uwsgi --socket :9000 --workers 4 --master --enable-threads --module app.wsgi

