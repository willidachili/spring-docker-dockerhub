# Docker & Cloud 9

# GitHub actions, AWS Lambda med API Gateway og AWS SAM

* I denne øvingen skal dere bli bedre kjent med Docker og hvordan pakker lager et Docker container Image av en Spring boot applikasjon. 
* Vi skal også sette opp en CI pipeline for å automatisk bygge et nytt container image på hver push til main branch.  

## Beskrivelse

## Lag en fork

Du må start med å lage en fork av dette repoet til din egen GitHub konto. 

## Logg i Cloud 9 miljøet ditt

* URL for innlogging er https://244530008913.signin.aws.amazon.com/console
* Logg på med brukernavn og passord gitt i klassrommet
* Gå til tjenesten Cloud9 (Du nå søke på Cloud9 uten mellomrom i søket)
* Velg "My environments" - pass på at du er i Ireland region.
* Velg "Open IDE"

### Lag et Access Token for GitHub

* Når du skal autentisere deg mot din GitHub konto fra Cloud 9 trenger du et access token.  Gå til  https://github.com/settings/tokens og lag et nytt.
* NB. Ta vare på tokenet et sted, du trenger dette senere når du skal gjøre ```git push```

![Alt text](img/generate.png  "a title")

Access token må ha "repo" tillatelser, og "workflow" tillatelser.

![Alt text](img/new_token.png  "a title")

### Lage en klone av din Fork (av dette repoet) inn i ditt Cloud 9 miljø

Fra Terminal i Cloud 9. Klone repository med HTTPS URL. Eksempel ;

```
git clone https://github.com/≤github bruker>/spring-docker-dockerhub.git
```

Får du denne feilmeldingen ```bash: /spring-docker-dockerhub: Permission denied``` - så glemte du å bytte ut <github bruker> med
ditt eget Github brukernavn :-)

![Alt text](img/clone.png  "a title")

## Konfigurer Git i Cloud9

(NB! Det kan hende du har gjort dette før)
Følgende steg trenger du bare gjøre en gang i Cloud9 miljøet ditt. Du kan hoppe over hele steget hvis du har gjort det tidligere.
For å slippe å autentisere seg hele tiden kan man få git til å cache nøkler i et valgfritt antall sekunder på denne måten.

```shell
git config --global credential.helper "cache --timeout=86400"
```

Konfigurer også brukernavnet og eposten din for GitHub CLI. Da slipepr du advarsler i terminalen
når du gjør commit senere.

````shell
git config --global user.name <github brukernavn>
git config --global user.email <email for github bruker>

````

#  "Dockerize"  en Spring Boot applikasjon og push til Docker hub

Verifiser at Docker er installert i Cloud 9

```docker run hello-world``` 

Forventet resultat  

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

Installer maven i Cloud 9.
```
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
```

Sjekk at du kan kjøre Spring Boot applikasjonen med Maven 
```
cd spring-docker-dockerhub
mvn spring-boot:run
```

Sjekk at applikasjonen kjører, hvis du liker terminalen ... 
```
curl localhost:8080                                                                                                            
```

Eller ikke ... Velg "Tools > Preview > Preview running application" I menyen i Cloud9 

Vi skal nå lage en Dockerfile for Spring boot applikasjonen. Vi skal bruke en "multi stage" Dockerfil, som 
først bygger applikasjonen, og deretter bruker den resulterende JAR filen til å lage en runtime container for applikasjonen. 

Les mer om multi stage builds her; https://docs.docker.com/develop/develop-images/multistage-build/

Kopier dette innholder inn i en  ```Dockerfile``` i rotkatalogen

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

Prøv å byggee en Docker container
```sh
docker build . --tag <give the image a name>
```

Prøv å starte en container basert dette container image.  
```sh
docker run <image name>:latest
```

Når du starter en container, så lytter ikke applikasjonen i Cloid 9 på port  8080. Hvorfor ikke ? Hint; port mapping 
Kan du start to versjoner av samme container, hvor en lytter på port 8080 og den andre på 8081?

## Registrer deg på Docker hub

https://hub.docker.com/signup

## Bygg en container og pish til Docker hub 

```
docker login
docker tag <tag> <dockerhub_username>/<tag_remote>
docker push <username>/<tag_remote>
```

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