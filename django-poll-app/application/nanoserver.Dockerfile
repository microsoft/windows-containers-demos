# FROM vclick2cloud/nanoserver:1.0
FROM mcr.microsoft.com/windows-cssc/python3.7.2nanoserver:ltsc2019
RUN md c:\windows_container\Django-poll-app\application

WORKDIR c:/windows_container/Django-poll-app/application

COPY . c:/windows_container/Django-poll-app/application

USER ContainerAdministrator
RUN python -m pip install --upgrade pip
USER ContainerUser

RUN pip install -r requirements.txt

RUN cmd python manage.py makemigrations

EXPOSE 8000

CMD python manage.py runserver 0.0.0.0:8000
