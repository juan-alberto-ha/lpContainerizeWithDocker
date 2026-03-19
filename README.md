# Containerize with Docker
## Milestone 1. 

### Create a Dockerfile for the database, and use Docker to test it. The image should set up the following:

- Database with name
- User
- User password


#### Dockerfile

Dockerfile looks like this:
```Dockerfile
# get latest version of postgres
FROM  postgres:latest
# set env variables
ENV POSTGRES_USER=user
ENV POSTGRES_PASSWORD=password
ENV POSTGRES_DB=my_db
EXPOSE 5432
# copy from local files to container
COPY init.sql  /docker-entrypoint-initdb.d/
# use volumes for persistence
VOLUME my-container-volume
```

#### The image
Build the image using buildx (BuildKit). For that I run the following on the path where the Dockerfile is stored.
```
sudo docker buildx build -t "juanalbertoha/m1containerize:latest" .
```

Now we can run the container:

```
sudo docker container run -d --name mypsql m1containerize:latest
```

To connect to the database we can use the ``docker exec`` command:
```
sudo docker exec -ti mypsql bash
```

#### Push image to Docker Hub

```
sudo docker push juanalbertoha/m1containerize:lates
```
