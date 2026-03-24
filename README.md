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
sudo docker container run -d --name mypsql juanalbertoha/m1containerize:latest
```

To connect to the database we can use the ``docker exec`` command:
```
sudo docker exec -ti mypsql bash
```

#### Push image to Docker Hub

```
sudo docker push juanalbertoha/m1containerize:latest
```

## Milestone 2.
### Run the existing application
#### Changes in source code
In order to run the existing application, after it has been downloaded, I have updated the Spring Boot version in the `pom.xml` file to `4.0.2`.
Then I had to change from `javax` to `jakarta` packages in `Match.java`.

In MatchControllerTest changed `MockBean` annotation to `org.springframework.test.context.bean.override.mockito.MockitoBean`.

#### Changes to Dockerfile in image to run postgresql
I have modified the values for user, password and database according to the source code of the Java application.

```Dockerfile
# get latest version of postgres
FROM  postgres:latest
# set env variables
ENV POSTGRES_USER=footer
ENV POSTGRES_PASSWORD=changeme
ENV POSTGRES_DB=footie
EXPOSE 5432
# copy from local files to container
COPY init.sql  /docker-entrypoint-initdb.d/
# use volumes for persistence https://docs.docker.com/engine/storage/volumes/  docker volume create postgres-data
VOLUME my-container-volume
```

Build the image with the modified values:
```
sudo docker buildx build -t "juanalbertoha/m1containerize:latest" .
```

#### Run the Postgresql container forwarding the port to localhost
```
sudo docker container run -d -p 5432:5432 --name mypsql juanalbertoha/m1containerize:latest
```

#### Run the Spring Boot application now in a Docker container

The `Dockerfile` is saved in the Spring Boot application directory and looks like this (note environment variable `FOOTIE_DB_HOST`):

```Dockerfile
FROM openjdk:19-ea-1-jdk
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENV FOOTIE_DB_HOST=mypsql
ENTRYPOINT ["java","-jar","/app.jar"]
```

We build the image:

```
sudo docker buildx build -t "juanalbertoha/m2containerizespringboot:latest" .
```
We have to make sure that the database is running and that both containers can communicate.

For users to communicate we establish a Docker network
```
sudo docker network create mynetwork

```
Run the database in that network:
```
sudo docker container run -d -p --network mynetwork --name mypsql juanalbertoha/m1containerize:latest

```
Now run the Spring Boot application in that network too.

```
sudo docker container run -d -p 12080:12080 --network mynetwork --name springbootapp juanalbertoha/m2containerizespringboot:latest
```

#### Use Docker Compose to run both containers
(Sample here: https://github.com/docker/awesome-compose/tree/master/spring-postgres )
Based on the work done above, we create the compose.yaml file.

```yaml
services:
  mypsql:
    image: juanalbertoha/m1containerize:latest
    volumes:
      - my-container-volume
    networks:
      - mynetwork
    expose:
      - 5432
  springbootapp:
    image: juanalbertoha/m2containerizespringboot:latest
    ports:
      - 12080:12080
    environment:
      - FOOTIE_DB_HOST=mypsql
    networks:
      - mynetwork
volumes:
  my-container-volume:
networks:
  mynetwork:
```

Run the containers withe Docker Compose:
```bash
sudo docker-compose up
```

We can check that the containers are running:
```bash
sudo docker container ls
CONTAINER ID   IMAGE                                           COMMAND                  CREATED         STATUS         PORTS                                             NAMES
013fbb4a0001   juanalbertoha/m1containerize:latest             "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   5432/tcp                                          milestone2_mypsql_1
6262a52a6521   juanalbertoha/m2containerizespringboot:latest   "java -jar /app.jar"     4 minutes ago   Up 4 minutes   0.0.0.0:12080->12080/tcp, [::]:12080->12080/tcp   milestone2_springbootapp_1
```

We can use `docker_compose` to check the logs:
```
sudo docker-compose logs
```
To stop the containers we use:
```bash
sudo docker compose down
```
