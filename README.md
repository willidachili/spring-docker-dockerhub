# Docker & Cloud 9

#  Dockerize a Spring Boot App and publish to Docker hub

Open your Cloud9 Environment. Instructions are given in the classroom
Verify that docker is installed in your Cloud9 environment.


```docker run hello-world``` 

Expected result

```Unable to find image hello-world:latest locally
 Pulling repository hello-world
 91c95931e552: Download complete
 a8219747be10: Download complete
 Status: 
 Downloaded newer image for hello-world:latest
 Hello from Docker.
 This message shows that your installation appears to be working correctly.

 To generate this message, Docker took the following steps:
  1. The Docker Engine CLI client contacted the Docker Engine daemon.
  2. The Docker Engine daemon pulled the "hello-world" image from the Docker Hub.
     (Assuming it was not already locally available.)
  3. The Docker Engine daemon created a new container from that image which runs the
     executable that produces the output you are currently reading.
  4. The Docker Engine daemon streamed that output to the Docker Engine CLI client, which sent it
     to your terminal.

 To try something more ambitious, you can run an Ubuntu container with:
  $ docker run -it ubuntu bash

 For more examples and ideas, visit:
  https://docs.docker.com/userguide/

```

Install required software in your cloud 9 environment
```
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
```

We are now going to use this cloud 9 environment to build and run a simple Spring Boot Application.
Go to the terminal in Cloud and and clone this repository

```
git clone https://github.com/PGR301-2021/04-cd-part-2.git
cd 04-cd-part-2
```

Make sure you can run the application with maven. 
```
mvn spring-boot:run
```

Make sure that the application is up and running

If you like the terminal
```
curl localhost:8080                                                                                                            
```
Or, select "Tools > Preview > Preview running application" in the Top menu bar of the Cloud 9 UI.

You will now create a Dockerfile to package the spring boot app into a container. Note that this is a multi stage docker file.
Read up on how they work here; https://docs.docker.com/develop/develop-images/multistage-build/

Copy this content into a file called ```Dockerfile``` in the same directory as the cloned source code. 
The file should be a sibling to the ```src``` directory where the Java code is. 

```dockerfile
FROM maven:3.6-jdk-11 as builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn package

FROM adoptopenjdk/openjdk11:alpine-slim
COPY --from=builder /app/target/*.jar /app/application.jar
ENTRYPOINT ["java","-jar","/app/application.jar"]

```

Build a container image using this docker file 

```sh
docker build . --tag <give the image a name>
```

You can now run the container image - and turn it into a container
```sh
docker run <image name>:latest
```

When you start the container. It will not respond to localhost on port 8080. Why? Remember port mapping? 
Try to start two container from the same image, one on port 8081 and one on 8080.

## Sign up for Docker hub

https://hub.docker.com/signup

## Build a container image and push it to Docker hub

It's very straight forward to push container images to Docker hub once you are authenticated. 
You create a tag under your Docker Hub user, that reference a local tag. And then push the Docker hub tag. 

```
docker login
docker tag <tag> <dockerhub_username>/<tag_remote>
docker push <username>/<tag_remote>
```

The "tag" is the tag you chose when you did ````docker build```` in the previous step.

Example:
```
docker login
docker tag fantasticapp glennbech/fantasticapp
docker push glennbech/fantasticapp
```

## Share the joy! 

Once the image is published to Docker hub. Publish the name in the Slack/Zoom channel so others can pull your container image.
Change the code and write a secret message instead of hello?

## Extra challenge 1: Create an ECR repository for your service

You'll need to find this out yourself :-) 
Can you do it from cloud9 using the CLI instead of the UI?

## Extra challenge 2: Push a container image to your ECR repository

* Authenticate Docker with ECR.
* This is "almost" done the same way you did with ```docker login``` to docker hub. 
* You need to figure out how to do this yourself! Google it. 

Example:
```sh

docker build -t myapp .
docker tag ecs-sample-app:latest xyz.dkr.ecr.us-east-2.amazonaws.com/ecs-sample-app
docker push xyz.dkr.ecr.us-east-2.amazonaws.com/myapp
```

## Extra challenge 3: Try to deploy this container to the AWS Apprunner Service

The AWS Apprunner service has a Wizard like interface/UI that lets you publish containers
straight to the internet - providing all infra for you. Find the Service in the AWS console and use it to deploy your web application, that has been pushed to ECR. 

## For extra credit 

* Look in the examples folder. Try to compile some go, and run MySQL on your computer with Docker
* Optimize build time and image size; https://whitfin.io/speeding-up-maven-docker-builds/
* Have a look at the Terraform coder in the infra directory ...