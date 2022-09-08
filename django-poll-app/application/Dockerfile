FROM click2cloud/nanoserver:1.0

RUN md C:\windows-containers-demos\django-poll-app\application

WORKDIR  C:/windows-containers-demos/django-poll-app/application

COPY . C:/windows-containers-demos/django-poll-app/application

RUN python -m pip install --upgrade pip

RUN pip install -r requirements.txt

RUN cmd python manage.py makemigrations

EXPOSE 8000

CMD python manage.py runserver 0.0.0.0:8000
