# get latest version of postgres
FROM  postgres:latest
# set env variables
ENV POSTGRES_USER=user
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=my_db
EXPOSE 5432
# copy from local files to container
COPY init.sql  /docker-entrypoint-initdb.d/
# use volumes for persistence https://docs.docker.com/engine/storage/volumes/  docker volume create postgres-data
VOLUME my-container-volume
