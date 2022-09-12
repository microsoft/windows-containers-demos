FROM mcr.microsoft.com/windows-cssc/python3.7.2nanoserver:ltsc2019

RUN md C:\windows-containers-demos\django-poll-app\application
WORKDIR C:/windows-containers-demos/django-poll-app/application
COPY . C:/windows-containers-demos/django-poll-app/application

RUN python -m pip install --upgrade pip --user --no-warn-script-location
RUN pip install -r requirements.txt
RUN cmd python manage.py makemigrations

EXPOSE 8000

CMD python manage.py runserver 0.0.0.0:8000